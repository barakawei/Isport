class EventRecommendation < Recommendation
  belongs_to :event, :foreign_key => "item_id"
  belongs_to :person

  def dispatch_recommendation( action=false )
    Dispatch.new(self.person.user, self.event,action).notify_user
  end

  def subscribers(user,action=false)
    user.befollowed_people
  end

  def notification_type( action=false )
    Notifications::RecommendationEvent
  end
end
