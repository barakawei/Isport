class NotificationsController < ApplicationController
  respond_to :js

  def index
    @notifications = Notification.includes( :actor ).where( :recipient_id => current_user,:type => "notifications::InviteEvent" )
    @notifications.each do |n|
      n.update_attributes( {:unread => 0} )
    end
    @unread_notify_count = Notification.sum(:unread, :conditions => "recipient_id = #{current_user.person.id} and type ='Notifications::InviteEvent'")
  end

end
