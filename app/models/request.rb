class Request < ActiveRecord::Base
  belongs_to :sender, :class_name => 'Person'
  belongs_to :recipient, :class_name => 'Person'

  def subscribers(user,action)
    [self.recipient]
  end
  
  def notification_type( action )
    Notifications::StartedSharing
  end
  
end
