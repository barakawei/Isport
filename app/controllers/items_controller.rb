class ItemsController < ApplicationController
  before_filter :authenticate_user!, :except => [:index, :show ]

  EVELIMIT = 6
  ACTLIMIT = 12
  ITELIMIT = 5

  def myitems
    @items_array = Item.get_user_items(current_user)
    @city = City.find_by_pinyin(current_user.city.pinyin)
    
    respond_to do |format|
      format.html # myitems.html.haml
      format.xml  { render :xml => @items_array }
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
    
    Event.week.joins(:location).select("subject_id, count(*) evesize")
      .where(:subject_id => items_ids, :locations => {:city_id => @city.id}).group(:subject_id).each do |count|
      events_counts[count.subject_id] = count.evesize
    end

    if current_user
      @myitems = [  ]
      current_user.person.interests.limit(ITELIMIT).each do |myitem| 
          @myitems.push({:item => myitem, :count=>events_counts[myitem.id]?events_counts[myitem.id]:0})
      end
    end

    Favorite.select("item_id, count(*) fansize")
      .where(:item_id => items_ids).group(:item_id).each do |count|
      fans_counts[count.item_id] = count.fansize
    end

    @items_hash = {  }
    @categories = Category.all
    @categories.each do |category|
      @items_hash[category.id] = [  ]  
    end

    @items.each do |item|
      @items_hash[item.category_id].push({:item => item, 
                                          :events_count => events_counts[item.id]?events_counts[item.id]:0, 
                                          :fans_count => fans_counts[item.id]?fans_counts[item.id]:0})
    end

    @categories.each do |category|
      @items_hash[category.id].sort!{ |x, y| y[:fans_count] <=> x[:fans_count] }
    end

    @select_tab = 'item'
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

    @events = Event.week.not_started.joins(:location).where(:subject_id => @item.id, :locations => {:city_id => @city.id})
        .limit(EVELIMIT)
  
    if @events.length < EVELIMIT
      pevents = Event.next_week.not_started.joins(:location).where(:subject_id => @item.id, :locations => {:city_id => @city.id})
        .limit(EVELIMIT-@events.length)

      if pevents
        @events += pevents
      end
    end

    @actors = Person.hot_stars(@item, ACTLIMIT)
    @groups = Group.joins(:members).where(:item_id => @item.id, :city_id => @city.id)
          .group(:group_id).order("count(group_id) DESC").limit(EVELIMIT)

    group_ids = @groups.map{|i| i.id}

    group_members_counts = { }
    group_topics_counts = { }
    group_events_counts = { }

    Membership.select("group_id, count(*) membersize").where(:group_id => group_ids, :pending => false)
      .group(:group_id).each do |count|
        group_members_counts[count.group_id] = count.membersize
    end


    Event.select("group_id, count(*) eventsize").where(:group_id => group_ids)
      .group(:group_id).each do |count|
        group_events_counts[count.group_id] = count.evesize
    end

    Topic.joins(:forum).select("forums.discussable_id group_id, count(*) topicsize")
      .where(:forums => {:discussable_id => group_ids, :discussable_type => "Group"}).group(:forum_id).each do |count|
        group_topics_counts[count.group_id] = count.topicsize
    end

    @groups_hash = []
    @groups.each do |group|
      @groups_hash.push({:group => group,
                        :membersize => group_members_counts[group.id]?group_members_counts[group.id]:0,
                        :eventsize => group_events_counts[group.id]?group_events_counts[group.id]:0,
                        :topicsize => group_topics_counts[group.id]?group_topics_counts[group.id]:0})      
    end

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
    Item.add_fan(params[:id], current_user)

    redirect_to(item_url(@item))
  end

  def remove_fan
    Item.remove_fan(params[:id], current_user)

    redirect_to(item_url(@item))
  end

  def add_fan_ajax
    Item.add_fan(params[:id], current_user) if params[:id]
    render :nothing => true
  end

  def remove_fan_ajax
    Item.remove_fan(params[:id], current_user)if params[:id]
    render :nothing => true
  end
end

