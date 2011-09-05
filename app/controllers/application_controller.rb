class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :set_header_data

  def registrations_closed?
    if AppConfig[ :registrations_closed ] && !user_signed_in?
      redirect_to sign_in_path
    end
  end

  def set_header_data
    if user_signed_in?
      @unread_message_count = ConversationVisibility.sum(:unread, :conditions => "person_id = #{current_user.id}")
      @notifications = Notification.includes( :actor ).where( :recipient_id => current_user).order( "created_at DESC" ).paginate(:page => params[:page], :per_page => 20)
      @unread_notify_count = Notification.sum(:unread, :conditions => "recipient_id = #{current_user.id} ")
      unpassed = 0
      @notifications.each do |n|
        if n.target_type == 'Event' || n.target_type == 'Group'
          if n.target.status != Event::PASSED || n.target.status != Group::PASSED
            if n.unread == 1
              unpassed = unpassed + 1
            end
          end
        end
      end
      @unread_notify_count = @unread_notify_count - unpassed

    end
  end

  def is_admin
    redirect_to events_path unless current_user.try(:admin?)
  end
end
