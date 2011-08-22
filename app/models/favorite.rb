class Favorite < ActiveRecord::Base
  belongs_to :person
  belongs_to :item, :counter_cache => :fans_count

  validates_uniqueness_of :item_id, :scope => :person_id
end
