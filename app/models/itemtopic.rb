class Itemtopic < ActiveRecord::Base
  belongs_to :theme

  has_many :itemtopicfollowships, :dependent => :destroy
  has_many :followers, :through => :itemtopicfollowships, :source => :person

end
