class StatusMessagesController < ApplicationController
  before_filter :registrations_closed?
  before_filter :authenticate_user!
  respond_to :js
  def create
    pics = Pic.where(:id => [*params[:photos]])
    item_topic = ItemTopic.where(:id => params[:topic_id]).first   
    @status_message =StatusMessage.initialize(current_user,params[ :contacts ])
    if !pics.empty?
      pics.each do |p|
        p.update_attributes(:description => params[:desc][p.id.to_s])
      end
      @status_message.pics << pics
    end
    
    @status_message.item_topic = item_topic if item_topic
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
end
