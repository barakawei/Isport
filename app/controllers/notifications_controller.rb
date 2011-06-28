class NotificationsController < ApplicationController
  respond_to :js
  def index
    @notifications = Notification.where( :recipient_id => current_user ).includes( :target )
    respond_with @notifications
  end

end
