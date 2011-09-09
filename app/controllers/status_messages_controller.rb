class StatusMessagesController < ApplicationController
  before_filter :registrations_closed?
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
    respond_with  @status_message
  end

  def show
    @post = Post.find( params[ :id ] )
  end

  def new
  end
end
