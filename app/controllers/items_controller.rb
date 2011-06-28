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

    Favorite.select("item_id, count(item_id) fansize")
      .where(:item_id => items_ids).group(:item_id).each do |count|
      fans_counts[count.item_id] = count.fansize
    end

    Event.this_week.select("subject_id, count(subject_id) evesize")
      .where(:subject_id => items_ids).group(:subject_id).each do |count|
      events_counts[count.subject_id] = count.evesize
    end

    @items_hash = [ ]
    @items.each do |item|
      @items_hash.push({:item => item, 
                        :fans_count=>fans_counts[item.id]?fans_counts[item.id]:0,
                        :events_count=>events_counts[item.id]?events_counts[item.id]:0})
    end

    respond_to do |format|
      format.html # myitems.html.haml
      format.xml  { render :xml => @items }
    end
  end

  def index
#    @items = Item.select("count(favorites.id) fans_count, items.* ")
#          .joins("left join favorites on items.id = favorites.item_id").group("items.id")

    @items = Item.all
    items_ids = @items.map{|i| i.id}

    fans_counts = {  }
    Favorite.select("item_id, count(item_id) fansize")
      .where(:item_id => items_ids).group(:item_id).each do |count|
      fans_counts[count.item_id] = count.fansize
    end
                    
    @items_hash=[ ]
    @items.each do |item|
      @items_hash.push({:item =>item, :fans_count=>fans_counts[item.id]?fans_counts[item.id]:0})
    end

    if current_user
      @myitems = [  ]
      current_user.person.interests.limit(ITELIMIT).each do |myitem| 
          @myitems.push({:item => myitem, :fans_count=>fans_counts[myitem.id]?fans_counts[myitem.id]:0})
      end
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @items }
    end
  end

  def show
    @item = Item.find(params[:id])
    @events = @item.events.this_week.limit(EVELIMIT)
    @actors = @item.fans.includes(:profile).limit(ACTLIMIT)

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

