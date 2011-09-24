class ItemTopicFollowship < ActiveRecord::Base
  belongs_to :person
  belongs_to :item_topic, :counter_cache => :followers_count
end
