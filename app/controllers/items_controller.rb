class ItemsController < ApplicationController
  before_filter :authenticate_user!, :except => [:index, :show ]

  EVELIMIT = 5
  ACTLIMIT = 8
  ITELIMIT = 5

  def myitems
    @items = current_user.person.interests 
    items_ids = @items.map{|i| i.id}

    fans_counts = {  }
    events_counts = {  }
    groups_counts = {  }  

    Favorite.select("item_id, count(item_id) fansize")
      .where(:item_id => items_ids).group(:item_id).each do |count|
      fans_counts[count.item_id] = count.fansize
    end

    if current_user
      @city = City.find_by_pinyin(current_user.city.pinyin)
    else
      @city = City.first
    end

    Event.week.joins(:location).select("subject_id, count(subject_id) evesize")
      .where(:subject_id => items_ids, :locations => {:city_id => @city.id}).group(:subject_id).each do |count|
      events_counts[count.subject_id] = count.evesize
    end

    Group.select("item_id, count(item_id) gpcount").where(:item_id => items_ids, :city_id => @city.id)
      .group(:item_id).each do |count|
      groups_counts[count.item.id] = count.gpcount
    end

    @items_hash = [ ]
    @items.each do |item|
      @items_hash.push({:item => item, 
                        :fans_count=>fans_counts[item.id]?fans_counts[item.id]:0,
                        :events_count=>events_counts[item.id]?events_counts[item.id]:0,
                        :groups_count=>groups_counts[item.id]?groups_counts[item.id]:0})
    end

    respond_to do |format|
      format.html # myitems.html.haml
      format.xml  { render :xml => @items }
    end
  end

  def index
    @items = Item.all
    items_ids = @items.map{|i| i.id}

    fans_counts = {  }
    events_counts = {  }
    if current_user
      @city = City.find_by_pinyin(current_user.city.pinyin)
    else
      @city = City.first      
    end
    
    Event.week.joins(:location).select("subject_id, count(subject_id) evesize")
      .where(:subject_id => items_ids, :locations => {:city_id => @city.id}).group(:subject_id).each do |count|
      events_counts[count.subject_id] = count.evesize
    end

    if current_user
      @myitems = [  ]
      current_user.person.interests.limit(ITELIMIT).each do |myitem| 
          @myitems.push({:item => myitem, :count=>events_counts[myitem.id]?events_counts[myitem.id]:0})
      end
    end

    Favorite.select("item_id, count(item_id) fansize")
      .where(:item_id => items_ids).group(:item_id).each do |count|
      fans_counts[count.item_id] = count.fansize
    end

    @items_hash=[ ]
    @items.each do |item|
      @items_hash.push({:item => item, 
                        :events_count => events_counts[item.id]?events_counts[item.id]:0, 
                        :fans_count => fans_counts[item.id]?fans_counts[item.id]:0})
    end

    @items_hash.sort!{ |x, y| y[:fans_count] <=> x[:fans_count] }

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @items }
    end
  end

  def show
    @item = Item.find(params[:id])

    if current_user
      @city = City.find_by_pinyin(current_user.city.pinyin)
    else
      @city = City.first
    end

    @events = Event.week.joins(:location).where(:subject_id => @item.id, :locations => {:city_id => @city.id})
        .limit(EVELIMIT)

    @actors = Person.joins(:involved_events).joins(:interests)
              .where(:events => {:subject_id => @item.id}, :items => {:id => @item.id}, 
                     :involvements => {:is_pending => false})
              .group("involvements.person_id").order("count(event_id) DESC").limit(ACTLIMIT).includes(:profile)

    @groups = Group.joins(:members).where(:item_id => @item.id, :city_id => @city.id)
          .group(:group_id).order("count(group_id) DESC").limit(ACTLIMIT)

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @item }
    end
  end

  def new
    @item = Item.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @item }
    end
  end

  def edit
    @item = Item.find(params[:id])
  end

  def create
    @item = Item.new(params[:item])

    respond_to do |format|
      if @item.save
        format.html { redirect_to(@item, :notice => 'Item was successfully created.') }
        format.xml  { render :xml => @item, :status => :created, :location => @item }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @item.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @item = Item.find(params[:id])

    respond_to do |format|
      if @item.update_attributes(params[:item])
        format.html { redirect_to(@item, :notice => 'Event was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @item.errors, :status => :unprocessable_entity }
      end
    end
  end

  def delete
    @item = Item.find(params[:id])
    if @item.events.size == 0
      @item.destroy
      redirect_to(items_url)
    else
      redirect_to(edit_item_path(@item), :notice => 'Can not delete item with events, Delete events first!')
    end
  end

  def add_fan
    @favorite = Favorite.new(:item_id => params[:id], :person_id => current_user.person.id)
    @favorite.save

    redirect_to(item_url(@item))
  end

  def remove_fan
    Favorite.delete_all(:item_id => params[:id], :person_id => current_user.person.id)

    redirect_to(item_url(@item))
  end
end

