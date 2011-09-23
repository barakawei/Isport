class Theme < ActiveRecord::Base
  belongs_to :item

  has_many :themefollowships, :dependent => :destroy
  has_many :followers, :through => :themefollowships, :source => :person

  has_many :itemtopics

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
     case size
        when :thumb_medium then "/images/event/event_medium.jpg"
        when :thumb_large   then "/images/event/event_large.jpg"
        when :thumb_small   then "/images/event/event_small.jpg"
     end
  end

  def self.add_follower(theme_id, person)
    followship = Themefollowship.new(:theme_id => item_id, :person_id => person.id)
    followship.save
  end

  def self.remove_follower(theme_id, person)
    Themefollowship.destroy_all(:theme_id => item_id, :person_id => person.id)
  end

end
