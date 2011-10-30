class ItemsController < ApplicationController
  before_filter :registrations_closed?
  before_filter :is_admin, :except => [:index, :show, :myitems, :add_fan, :remove_fan, :add_fan_ajax, :remove_fan_ajax ]
  respond_to :js 

  EVELIMIT = 6
  ACTLIMIT = 12

  def myitems
    @items_array = Item.get_user_items(current_user)
    @city = City.find(current_user.city.id)
    
    @select_tab = 'item'
    respond_to do |format|
      format.html # myitems.html.haml
      format.xml  { render :xml => @items_array }
    end
  end

  def index
    @categories = Category.all
    @myitems = []

    if current_user
      @city = City.find(current_user.city.id)
    else
      @city = nil      
    end

    @items_hash = Item.all_items(@categories, @myitems, @city, current_user)
    @hot_items = Item.hot_items(7, @city) 
    @select_tab = 'item'
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @items }
    end
  end

  def show
    @item = Item.find(params[:id])

    if current_user
      @city = City.find(current_user.city.id)
    else
      @city = City.first
    end

    @events = @item.hot_events(EVELIMIT, @city)  
    @actors = @item.hot_stars(ACTLIMIT)
    @groups = @item.hot_groups(EVELIMIT, @city) 

    @topics = ItemTopic.of_item(@item).recent_hot.limit(50)
    @topics = ItemTopic.of_item(@item).order_by_hot.limit(50) unless @topics.length > 0
    @topics = @topics.sort_by{rand}[0..7]

    @select_tab = 'item'
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

    if @item.events.size == 0 && @item.groups.size == 0
      @item.destroy
      redirect_to(items_url)
    else
      redirect_to(edit_item_path(@item), :notice => 'Can not delete item with events, Delete events first!')
    end
  end

  def add_fan
    Item.add_fan(params[:id], current_user.person)

    redirect_to(item_url(@item))
  end

  def remove_fan
    Item.remove_fan(params[:id], current_user.person)

    redirect_to(item_url(@item))
  end

  def add_fan_ajax
    Item.add_fan(params[:id], current_user.person) if params[:id]
    render :nothing => true
  end

  def remove_fan_ajax
    Item.remove_fan(params[:id], current_user.person)if params[:id]
    render :nothing => true
  end

  def is_admin
    raise ActionController::RoutingError.new("such action only can be exeute by admin") unless current_user.try(:admin?)
  end

end

