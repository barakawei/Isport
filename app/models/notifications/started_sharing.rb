class Notifications::StartedSharing < Notification
  has_many :people, :through => :notification_actors

  def translation_key
    "notifications.started_sharing"
  end

end 

