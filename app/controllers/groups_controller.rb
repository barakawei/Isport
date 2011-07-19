class GroupsController < ApplicationController
  prepend_before_filter :authenticate_user!, :except => [:index, :show] 
  before_filter :init, :except => [:index, :show] 
  
  def index
    city_pinyin = params[:city] ? params[:city] : (current_user ? current_user.city.pinyin : City.first.pinyin)
    @city = City.find_by_pinyin(city_pinyin)
    @groups = Group.all
    @hot_groups = Group.limit(3);
    @hot_items = Item.all 
  end

  def show
    @group = Group.find(params[:id])
    @members = @group.members.limit(9)
    @current_person = current_user.person
    @topics = @group.topics
    @topics.each {|t| t.url = group_topic_path(@group, t)}
  end

  def new
    @group = Group.new
    @group.city = City.first
  end

  def edit
    @group = Group.find(params[:id])
  end

  def create
    @group = Group.new(params[:group])
    @group.person = current_user.person
    @group.members << current_user.person
    @group.forum = Forum.create

    respond_to do |format|
      if @group.save
        format.html { redirect_to(@group, :notice => 'Group was successfully created.') }
      else
        format.html { render :action => "new" }
      end
    end
  end

  def update
    @group = Group.find(params[:id])

    respond_to do |format|
      if @group.update_attributes(params[:group])
        format.html { redirect_to(@group, :notice => 'Group was successfully updated.') }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  def destroy
    @group = Group.find(params[:id])
    @group.destroy

    redirect_to(groups_url) 
  end

  def members
    @group = Group.find(params[:id])
    @members = @group.members.paginate :page => params[:page], :per_page => 10
  end

  def forum
    @group = Group.find(params[:id])
    @forum = @group.forum
    @topics = []
    if @forum.topics.count > 0  
      @topics= @forum.topics.paginate :page => params[:page], 
                                      :per_page => 20, :order => 'created_at desc' 
      @topics.each {|t| t.url = group_topic_path(@group, t)}
    end
  end

  def filtered
    city_pinyin = params[:city] ? params[:city] : (current_user ? current_user.city.pinyin : City.first.pinyin)
    @city = City.find_by_pinyin(city_pinyin)
    @district_id = params[:district_id]
    @item_id = params[:item_id]
    search_hash = {:city_id => @city.id}
    search_hash[:item_id] = @item_id unless @item_id.nil?
    search_hash[:district_id] = @district_id unless @district_id.nil?
    @groups = Group.filter_group(search_hash).paginate :page => params[:page], 
                                                       :per_page => 16
  end

  private

  def init
    @current_person = current_user.person    
  end
end
