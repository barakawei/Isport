class ItemTopicsController < ApplicationController
  before_filter :registrations_closed?
  before_filter :is_admin, :except => [:index, :show ]
  respond_to :js 

  FOLLOWER = 12

  def show
    @topic = ItemTopic.find(params[:id]) 
    @followers = @topic.followers.limit(FOLLOWER).includes(:profile) 
     
  end

  def is_admin
    raise ActionController::RoutingError.new("such action only can be exeute by admin") unless current_user.try(:admin?)
  end

  def create
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
