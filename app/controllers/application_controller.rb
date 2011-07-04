class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :set_header_data


  def set_header_data
    if user_signed_in?
      @unread_message_count = ConversationVisibility.sum(:unread, :conditions => "person_id = #{current_user.person.id}")
    end
  end
  
end
