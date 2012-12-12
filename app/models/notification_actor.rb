class NotificationActor < ActiveRecord::Base
  belongs_to :notification
  belongs_to :person
  belongs_to :target, :polymorphic => true   
  after_destroy :delete_notification

  def delete_notification
    na = NotificationActor.where( :notification_id => self.notification )
    if na.length == 0
      Notification.where(:id => self.notification).delete_all
    end
  end
end
