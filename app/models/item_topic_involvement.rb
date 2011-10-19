class ItemTopicInvolvement < ActiveRecord::Base
  belongs_to :person
  belongs_to :item_topic
end
