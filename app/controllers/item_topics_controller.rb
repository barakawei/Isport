class ItemTopicsController < ApplicationController
  before_filter :registrations_closed?
  before_filter :is_admin, :except => [:index, :show ]

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

end
