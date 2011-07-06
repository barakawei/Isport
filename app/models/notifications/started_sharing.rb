class Notifications::StartedSharing < Notification

  def translation_key
    "notifications.started_sharing"
  end

  private

  def self.make_notification(recipient, target, actor, notification_type)
    super(recipient, target.sender, actor, notification_type)
  end

end 

