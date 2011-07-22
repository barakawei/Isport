class StatusMessagesController < ApplicationController
  before_filter :authenticate_user!

  respond_to :js
  def create
    photos = Photo.where(:id => [*params[:photos]])
    @status_message =StatusMessage.initialize(current_user,params[:status_message])
    if !photos.empty?
      @status_message.photos << photos
    end
    
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
