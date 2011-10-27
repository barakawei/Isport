class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :set_header_data,:except => [:refresh_count,:refresh]
  before_filter :set_last_request_at,:except => [:refresh,:refresh_count]

  def registrations_closed?
    if AppConfig[ :registrations_closed ] && !user_signed_in?
      redirect_to sign_in_path
    end
  end

  def set_last_request_at 
    current_user.update_attribute(:last_request_at, Time.now) if user_signed_in? 
  end 
  

  def set_header_data
    if user_signed_in?
      @unread_message_count = ConversationVisibility.sum(:unread, :conditions => "person_id = #{current_user.person.id}")
      @unread_notify_count = Notification.sum(:unread, :conditions => "recipient_id = #{current_user.id} ")
    end
  end

  def is_admin
    raise ActionController::RoutingError.new("not such route") unless current_user.try(:admin?)
  end

end
