class ItemTopicsController < ApplicationController
  before_filter :registrations_closed?
  before_filter :is_admin, :except => [:index, :show ]
  respond_to :js 

  FOLLOWER = 12

  def show
    @topic = ItemTopic.find(params[:id]) 
    @followers = @topic.followers.limit(FOLLOWER).includes(:profile) 
     
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
    @topic = ItemTopic.find(params[:id])
    @topic.add_follower(current_user.person) if params[:id]
    respond_with @topic
  end

  def defollow
    @topic = ItemTopic.find(params[:id])
    @topic.remove_follower(current_user.person) if params[:id]
    respond_with @topic
  end
end
