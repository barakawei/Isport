class StatusMessagesController < ApplicationController
  before_filter :authenticate_user!

  def create
    @status_message =StatusMessage.initialize(current_user,params[:status_message])
    if @status_message.save
      @status_message.dispatch_post 
    end
    
    redirect_to :back
  end
end
