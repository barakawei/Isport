class Itemtopicfollowship < ActiveRecord::Base
  belongs_to :person
  belongs_to :itemtopic, :counter_cache => :followers_count

end
