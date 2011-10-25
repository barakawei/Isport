class NotificationsController < ApplicationController
  include NotificationsHelper
  before_filter :registrations_closed?
  respond_to :js
  def index
    notifications_temp = Notification.includes( :actor ).where( :recipient_id => current_user).order( "created_at DESC" ).all

    @unread_notify_count = Notification.sum(:unread, :conditions => "recipient_id = #{current_user.id}")
    notifications_t = Array.new( notifications_temp )

    unpassed = 0
    notifications_temp.each do |n|
      if n.target
        n[:actor] = n.actor
        n[:translation] = object_link(n)
        n[:translation_key] = n.translation_key
        n[:target] = n.target
        if n.target_type == 'Event' || n.target_type == 'Group'
          if n.target.status != Event::PASSED || n.target.status != Group::PASSED
            if n.unread == 1
              unpassed = unpassed + 1
            end
            notifications_t.delete( n )
          end
        end
      else
        notifications_t.delete( n )
        if n.unread == 1
          unpassed = unpassed + 1
        end
      end
    end
    @unread_notify_count = @unread_notify_count - unpassed
    @notifications = Array.new( notifications_t ).paginate(:page => params[:page], :per_page => 20)
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
      notifications = Notification.includes( :actor ).where( :recipient_id => current_user).order( "created_at DESC" )
      @unread_notify_count = Notification.sum(:unread, :conditions => "recipient_id = #{current_user.id} ")
      unpassed = 0
      notifications.each do |n|
        if n.target
          if n.target_type == 'Event' || n.target_type == 'Group'
            if n.target.status != Event::PASSED || n.target.status != Group::PASSED
              if n.unread == 1
                unpassed = unpassed + 1
              end
            end
          end
        else
          if n.unread == 1
            unpassed = unpassed + 1
          end
        end
      end
      @unread_notify_count = @unread_notify_count - unpassed
    end
    respond_with [ @unread_message_count,@unread_notify_count ]
  end
end
