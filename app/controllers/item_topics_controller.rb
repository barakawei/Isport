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
    order_type = params[:order] ? params[:order] : 'order_by_time'
    @item = Item.find(params[:item_id])
    if order_type == 'order_by_time'
      @item_topics = ItemTopic.of_item(@item).order('created_at desc').paginate :page => params[:page],
                                                       :per_page => 15 
    else
      @item_topics = ItemTopic.of_item(@item).order('posts_count desc').paginate :page => params[:page],
                                                       :per_page => 15 
    end
    @sort_by_time = search_item_topic_path(@item)
    @sort_by_hot= search_item_topic_path(@item, 'order_by_hot')
    render :action => :index 
  end

  def index
    order_type = params[:order] ? params[:order] : 'order_by_time'
    if order_type == 'order_by_time'
      @item_topics = ItemTopic.order('created_at desc').paginate :page => params[:page],
                                            :per_page => 15 
    else
      @item_topics = ItemTopic.order('posts_count desc').paginate :page => params[:page],
                                            :per_page => 15 
    end
    @sort_by_time = item_topics_path
    @sort_by_hot = item_topics_path('order_by_hot')
  end

  def interested
    order_type = params[:order] ? params[:order] : 'order_by_time'
    @interests = current_user.person.interests
    if order_type == 'order_by_time'
      @item_topics = ItemTopic.in_items(@interests).order('created_at desc').paginate :page => params[:page],
                                                 :per_page => 15 
    else
      @item_topics = ItemTopic.in_items(@interests).order('posts_count desc').paginate :page => params[:page],
                                                 :per_page => 15 
    end
    @sort_by_time= interested_topics_path()
    @sort_by_hot= interested_topics_path('order_by_hot')
    render :action => :index 
  end

  def friends
    order_type = params[:order] ? params[:order] : 'order_by_time'
    @friends = current_user.friends 
    if order_type == 'order_by_time'
      @item_topics = ItemTopic.by_friends(@friends).order('created_at desc').paginate :page => params[:page],
                                                 :per_page => 15 
    else
      @item_topics = ItemTopic.by_friends(@friends).order('posts_count desc').paginate :page => params[:page],
                                                 :per_page => 15 
    end
    @sort_by_time= friends_topics_path()
    @sort_by_hot= friends_topics_path('order_by_hot')
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
