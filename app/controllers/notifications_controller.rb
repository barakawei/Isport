class NotificationsController < ApplicationController
  include NotificationsHelper
  before_filter :registrations_closed?
  respond_to :js
  def index
    @notifications = Notification.includes( :actor ).where( :recipient_id => current_user).order( "created_at DESC" ).paginate(:page => params[:page], :per_page => 20)
    @unread_notify_count = Notification.sum(:unread, :conditions => "recipient_id = #{current_user.id}")

    @notifications.each do |n|
        n[:actor] = n.actor
        n[:translation] = object_link(n)
        n[:translation_key] = n.translation_key
        n[:target] = n.target
    end
    noti_ids = @notifications.map{ |n|n.id }
    Notification.update_all ["unread=0"],["id in (?)",noti_ids]
    respond_to do |format|  
      format.json { render :json => { :notifications => @notifications}}    
      format.html { render 'index.html.haml' }
    end 
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
