class StatusMessagesController < ApplicationController
  before_filter :registrations_closed?
  before_filter :authenticate_user!
  respond_to :js
  def create
    auth = current_user.authorizations.first
    pics = Pic.where(:id => [*params[:photos]])
    item_topic = ItemTopic.where(:id => params[:topic_id]).first   
    @status_message = StatusMessage.initialize(current_user, params[:contacts])
    if !pics.empty?
      pics.each do |p|
        p.update_attributes(:description => params[:desc][p.id.to_s])
      end
      @status_message.pics << pics
    end
    if item_topic
      @status_message.item_topic = item_topic 
      @status_message.item = item_topic.item 
      ItemTopicInvolvement.find_or_create_by_item_topic_id_and_person_id(:item_topic_id => item_topic.id, :person_id => current_user.person.id) 
    end
    if @status_message.save
      @status_message.create_video
      if params['sina_weibo'] == 'yes' && auth
        if pics.empty?
          auth.create_weibo(@status_message.weibo_status("http://#{request.host}:#{request.port}/item_topics/"))
        else
          auth.create_weibo_with_photo(@status_message.weibo_status("http://#{request.host}:#{request.port}/item_topics/"), pics.first.weibo_image_file)
        end
      end
      #@status_message.dispatch_post 
    end
    respond_with @status_message
  end

  def show_post_video
    @video = PostVideo.find(params[:id]) 
    render :partial => 'status_messages/video_player',  :locals => {:video => @video}
  end

  def show
    @post = Post.find( params[ :id ] )
  end

  def new
    @status_message = StatusMessage.new
  end

  def pic_upload
    render "status_messages/_add_pic.html.haml",:layout => false
  end

  def destroy
    @status_message = StatusMessage.find(params[:id])
    if current_user.person.id == @status_message.author.id
      @status_message.destroy
      respond_with @status_message
    end 
  end

  def refresh
    if params[ :id ]
      @topic = ItemTopic.find(params[:id]) 
      @posts = @topic.posts.refresh( current_user ).order( "posts.created_at DESC" )
    else
      followed_people = current_user.followed_people
      people_id = followed_people.map{|p| p.id} + [current_user.person.id]
      followed_itemtopic_ids = current_user.person.concern_itemtopics.map{|i| i.id}
      followed_item_ids = current_user.person.interests.map{ |i| i.id}
      @posts = Post.where("item_topic_id in (?) or item_id in (?)",followed_itemtopic_ids,followed_item_ids).where( "type='StatusMessage'" ).refresh( current_user ).order( "posts.created_at DESC" )
    end
    respond_with @posts
  end

  def refresh_update
    render :nothing => true
  end
end
