class Itemtopic < ActiveRecord::Base
  belongs_to :item
  has_many :itemtopicfollowships, :dependent => :destroy
  has_many :followers, :through => :itemtopicfollowships, :source => :person

  has_many :posts 

  def image_url(size = :thumb_large)
    result = if size == :thumb_medium && self[:image_url_medium]
       self[:image_url_medium]
     elsif size == :thumb_small && self[:image_url_small]
       self[:image_url_small]
     else
       self[:image_url_large]
     end
    (result != nil && result.length > 0) ? result : default_url(size)
  end

  def default_url(size)
    self.item.image_url(size) 
  end

  def self.add_follower(itemtopic_id, person)
    followship = Itemtopicfollowship.new(:itemtopic_id => item_id, :person_id => person.id)
    followship.save
  end

  def self.remove_follower(itemtopic_id, person)
    Itemtopicfollowship.destroy_all(:itemtopic_id => item_id, :person_id => person.id)
  end

end
