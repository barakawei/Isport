class StatusMessagesController < ApplicationController
  before_filter :authenticate_user!

  respond_to :js
  def create
    @status_message =StatusMessage.initialize(current_user,params[:status_message])
    if @status_message.save
      @status_message.dispatch_post 
    end
    if params[ :view ] == "index"
      render :template => "status_messages/create_index"
    else
      respond_with  @status_message
    end 
  end
end
