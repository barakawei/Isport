class ItemTopicsController < ApplicationController
  before_filter :registrations_closed?
  before_filter :is_admin, :except => [:index, :show ]
  respond_to :js 

  FOLLOWER = 12
  RELATED = 8

  def show
    @topic = ItemTopic.find(params[:id]) 
    @followers = @topic.followers.limit(FOLLOWER).includes(:profile) 
    @related = @topic.item.topics.where("id != ?", @topic.id).order("created_at DESC").limit(RELATED)
  end

  def filter 
    @person = current_user.person
    @item_topics = ItemTopic.send(params[:target], @person).send(params[:order])
    render :partial => 'filter', :locals => {:topics => @item_topics}
  end

  def search
    @item = Item.find(params[:item_id])
    @item_topics = ItemTopic.of_item(@item).order('created_at desc').paginate :page => params[:page],
                                                     :per_page => 15 
    render :action => :index 
  end

  def index
    @item_topics = ItemTopic.order('created_at desc').paginate :page => params[:page],
                                          :per_page => 15 
  end

  def interested
    @interests = current_user.person.interests
    @item_topics = ItemTopic.in_items(@interests).order('created_at desc').paginate :page => params[:page],
                                               :per_page => 15 
    render :action => :index 
  end

  def friends
    @friends = current_user.friends 
    @item_topics = ItemTopic.by_friends(@friends).order('created_at desc').paginate :page => params[:page],
                                               :per_page => 15 
    render :action => :index 
  end

  def create
    @current_person = current_user.person
    @topic = ItemTopic.new(params[:item_topic])
    @topic.person = @current_person  
    puts params[:format]
    if @topic.save
      if params[:format] == 'json'  
        render :xml=> @topic.to_xml
      else
        redirect_to item_topic_path(@topic)
      end
    else
      respond_to do |format|
        format.html{ render :action => :new }
        format.json { render :text => @topic.to_json }
      end
    end
  end

  def follow
    ItemTopic.add_follower(params[:id], current_user.person) if params[:id]
    @topic = ItemTopic.find(params[:id])

    respond_with @topic
  end

  def defollow
    ItemTopic.remove_follower(params[:id], current_user.person) if params[:id]
    @topic = ItemTopic.find(params[:id])
    
    respond_with @topic
  end
end
