class Itemtopicfollowship < ActiveRecord::Base
  belongs_to :person
  belongs_to :itemtopic

end
