class ItemTopicsController < ApplicationController
  before_filter :registrations_closed?
  before_filter :is_admin, :except => [:index, :show ]

  def show
    @topic = ItemTopic.find(params[:id]) 

  end

  def is_admin
    raise ActionController::RoutingError.new("such action only can be exeute by admin") unless current_user.try(:admin?)
  end

end
