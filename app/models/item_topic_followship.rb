class ItemTopicFollowship < ActiveRecord::Base
  belongs_to :person
  belongs_to :item_topic, :counter_cache => :followers_count

  validates_uniqueness_of :item_topic_id, :scope => :person_id
end
