class Request < ActiveRecord::Base
  belongs_to :sender, :class_name => 'Person'
  belongs_to :recipient, :class_name => 'Person'

  def subscribers(user)
    [self.recipient]
  end
  
  def notification_type(user, person)
    Notifications::StartedSharing
  end
  
end
