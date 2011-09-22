class Theme < ActiveRecord::Base
  belongs_to :item

  has_many :themefollowships, :dependent => :destroy
  has_many :followers, :through => :themefollowships, :source => :person

end
