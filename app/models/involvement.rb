class Involvement < ActiveRecord::Base
  belongs_to :person
  belongs_to :event

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
