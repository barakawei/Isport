class NotificationsController < ApplicationController
  include NotificationsHelper
  def index
    @notifications = Notification.includes( :actor ).where( :recipient_id => current_user).order( "created_at DESC" )

    @unread_notify_count = Notification.sum(:unread, :conditions => "recipient_id = #{current_user.person.id}")
    
    @notifications.each do |n|
      n[:actor] = n.actor
      n[:translation] = object_link(n)
      n[:translation_key] = n.translation_key
      n[:target] = n.target
    end
    
    respond_to do |format|  
      format.json { render :json => { :notifications => @notifications}}    
    end 
    
  end

end
