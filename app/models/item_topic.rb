class ItemTopic < ActiveRecord::Base
  belongs_to :item
  belongs_to :person

  has_many :item_topic_followships, :dependent => :destroy
  has_many :followers, :through => :item_topic_followships, :source => :person

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
    if self.item
      self.item.image_url(size) 
    else
      case size
         when :thumb_medium then "/images/item_topic/medium.png"
         when :thumb_large   then "/images/item_topic/large.png"
         when :thumb_small   then "/images/item_topic/small.png"
      end
    end
  end

  def add_follower(person)
    followship = ItemTopicFollowship.new(:item_topic_id => self.id, :person_id => person.id)
    followship.save
  end

  def remove_follower(person)
    ItemTopicFollowship.destroy_all(:item_topic_id => self.id, :person_id => person.id)
  end

end
