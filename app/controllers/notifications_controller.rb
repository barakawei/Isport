class NotificationsController < ApplicationController
  include NotificationsHelper
  before_filter :registrations_closed?
  def index
    @notifications = Notification.includes( :actor ).where( :recipient_id => current_user).order( "created_at DESC" ).paginate(:page => params[:page], :per_page => 20)

    @unread_notify_count = Notification.sum(:unread, :conditions => "recipient_id = #{current_user.person.id}")

    unpassed = 0
    @notifications.each do |n|
      if n.target_type == 'Event' || n.target_type == 'Group'
        if n.target.status != Event::PASSED || n.target.status != Group::PASSED
          if n.unread == 1
            unpassed = unpassed + 1
          end
          @notifications.delete( n )
        end
      end
      n[:actor] = n.actor
      n[:translation] = object_link(n)
      n[:translation_key] = n.translation_key
      n[:target] = n.target
    end
    @unread_notify_count = @unread_notify_count - unpassed
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
