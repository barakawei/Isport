class EventRecommendation < Recommendation
  after_create :update_owner_counter
  after_destroy :update_owner_counter
  after_update :update_owner_counter

  belongs_to :event, :foreign_key => "item_id"
  belongs_to :person

  def update_owner_counter
    e = self.event
    e.update_attributes(:fans_count => e.recommendations.count) 
  end

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
