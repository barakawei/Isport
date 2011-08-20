class NotificationsController < ApplicationController
  include NotificationsHelper
  before_filter :registrations_closed?
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

  def read_all(opts=params)
    Notification.where(:recipient_id => current_user.id).update_all(:unread => false)
  end
  
end
