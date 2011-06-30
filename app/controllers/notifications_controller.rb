class NotificationsController < ApplicationController
  respond_to :js

  def index
    @notifications = Notification.includes( :actor ).where( :recipient_id => current_user )
    respond_with @notifications
  end

end
