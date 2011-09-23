class ItemtopicComment < ActiveRecord::Base
  belongs_to :person
  belongs_to :itemtopic, :counter_cache => true

end
