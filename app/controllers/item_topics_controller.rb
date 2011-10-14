class ItemTopicsController < ApplicationController
  before_filter :registrations_closed?
  respond_to :js 

  FOLLOWER = 12
  RELATED = 12

  def show
    auth = current_user.authorizations.first
    @is_binded = !auth.nil?
    @topic = ItemTopic.find(params[:id]) 
    @followers = @topic.followers.order('rand()').limit(FOLLOWER).includes(:profile) 
    @related = ItemTopic.of_item(@topic.item).recent_hot.where("id != ?", @topic.id).limit(50)
    @related = @related.sort_by{rand}[0..RELATED]
  end

  def show_posts
    @topic = ItemTopic.find(params[:id]) 
    @posts = @topic.posts.order( "posts.created_at DESC" ).paginate(:page => params[:page], :per_page => 30)
    respond_with @posts
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

  def update
    @topic = ItemTopic.find(params[:id]) 

    @topic.update_attributes(params[:item_topic])
    if params[:format] == 'xml'  
      render :xml=> @topic.to_xml
    end
  end

  def create
    @current_person = current_user.person

    item = Item.find(params[:item_topic][:item_id])
    @existed_topics = item.topics.where(:name => params[:item_topic][:name])
    if @existed_topics.size > 0
      @topic = @existed_topics.first 
    else
      @topic = ItemTopic.new(params[:item_topic])
      @topic.person = @current_person 
    end
    if @topic.save
      ItemTopic.add_follower(@topic.id, @current_person)
      if params[:format] == 'xml'  
        render :xml=> @topic.to_xml
      else
        redirect_to item_topic_path(@topic)
      end
    else
      respond_to do |format|
        format.html{ render :action => :new }
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

  def recent_topics
    @topics = ItemTopic.recent_random_topics 
    render :partial => 'item_topics/recent_topics', :locals => {:topics => @topics} 
  end
end
