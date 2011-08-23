class Involvement < ActiveRecord::Base
  after_create :update_owner_counter
  after_destroy :update_owner_counter
  after_update :update_owner_counter

  belongs_to :person
  belongs_to :event
  
  def update_owner_counter
    e = self.event
    e.update_attributes(:participants_count => e.participants.count) 
  end

  def subscribers(user,action=false)
    user.befollowed_people
  end

  def notification_type( action=false )
    Notifications::InvolvmentEvent
  end
  
  def dispatch_involvment( action=false )
    Dispatch.new(self.person.user, self.event,action).notify_user
  end

end
