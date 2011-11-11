class NotificationsController < ApplicationController
  include NotificationsHelper
  before_filter :registrations_closed?
  respond_to :js,:html
  def index
    @notifications = Notification.where( :recipient_id => current_user).order( "updated_at DESC" ).paginate(:page => params[:page], :per_page => 20).all
    @unread_notify_count = Notification.sum(:unread, :conditions => "recipient_id = #{current_user.id}")

    @notifications.each do |n|
        n[:url] = n.actor.first.profile.image_url( :thumb_small )
        n[ :size ] = n.actor.size
        n[:translation] = object_link(n)
        n[:translation_key] = n.translation_key
        n[:target] = n.target
    end
    #Notification.update_all ["unread=0"],["unread = 1"]
    respond_to do |format|  
      format.json { render :json => { :notifications => @notifications}}    
      format.html { render 'index.html.haml' }
    end 
  end

  def notifications_detail
    @notifications = Notification.where( :recipient_id => current_user).order( "updated_at DESC" ).paginate(:page => params[:page], :per_page => 20)
    respond_with @notifications
  end

  def update(opts=params)
    note = Notification.where(:recipient_id => current_user.id, :id => opts[:id]).first
    if note
      note.update_attributes(:unread => false)
      render {}
    else
      Response.new :status => 404
    end
  end

  def refresh_count
    if user_signed_in?
      @unread_message_count = ConversationVisibility.sum(:unread, :conditions => "person_id = #{current_user.person.id}")
      @unread_notify_count = Notification.sum(:unread, :conditions => "recipient_id = #{current_user.id} ")
    end
    respond_with [ @unread_message_count,@unread_notify_count ]
  end
end
