class StatusMessagesController < ApplicationController
  before_filter :registrations_closed?
  before_filter :authenticate_user!
  respond_to :js
  def create
    pics = Pic.where(:id => [*params[:photos]])
    @status_message =StatusMessage.initialize(current_user,params[ :contacts ])
    if !pics.empty?
      pics.each do |p|
        p.update_attributes(:description => params[:desc][p.id.to_s])
      end
      @status_message.pics << pics
    end
    
    if @status_message.save
      @status_message.dispatch_post 
    end
    respond_with @status_message
  end

  def show
    @post = Post.find( params[ :id ] )
  end

  def new
    @status_message = StatusMessage.new
  end

  def destroy
    @status_message = StatusMessage.find(params[:id])
    if current_user.person.id == @status_message.author.id
      @status_message.destroy
      respond_with @status_message
    end 
  end
end
