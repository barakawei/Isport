class Notifications::InviteEvent < Notification
  def translation_key
    "notifications.invite_event"
  end

  def translation_link_key
    "notifications_link.invite_event"
  end
end 
