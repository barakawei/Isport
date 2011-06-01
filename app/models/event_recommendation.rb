class EventRecommendation < Recommendation
  belongs_to :event, :foreign_key => "item_id"
  belongs_to :person
end
