class ItemsController < ApplicationController
  before_filter :authenticate_user!, :except => [:index, :show ]

  EVELIMIT = 8
  ACTLIMIT = 8
  ITELIMIT = 3

  def myitems
    @items = current_user.person.interests 

    respond_to do |format|
      format.html # myitems.html.haml
      format.xml  { render :xml => @items }
    end
  end

  def index
    @items = Item.all
    @myitems = current_user.person.interests.slice(0, ITELIMIT) 

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @items }
    end
  end

  def show
    @item = Item.find(params[:id])
    @events = @item.events.reject{|n| n.start_at.past?}.sort_by{|u| u.start_at}.slice(0, EVELIMIT)
    @actors = @item.fans.slice(0,ACTLIMIT)

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
    @item = Item.find(params[:id])
    @item.fans << current_user.person
    
    redirect_to(item_url(@item))
  end

  def remove_fan
    @item = Item.find(params[:id])
    @item.fans.delete(current_user.person)
    
    redirect_to(item_url(@item))
  end
end
