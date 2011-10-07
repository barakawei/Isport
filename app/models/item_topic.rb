class ItemTopic < ActiveRecord::Base
  belongs_to :item
  belongs_to :person

  has_many :item_topic_followships, :dependent => :destroy
  has_many :followers, :through => :item_topic_followships, :source => :person

  has_many :posts 
  belongs_to :person

  scope :of_person, lambda {|person| where(:person_id => person)}
  scope :order_by_time, lambda {order('created_at desc') }
  scope :order_by_hot, lambda { order('posts_count desc') }
  scope :of_item, lambda {|item| where(:item_id => item.id)}
  scope :in_items, lambda {|items| where(:item_id => items) }
  scope :by_friends, lambda {|friends| where(:person_id => friends) }

  def self.mine(person)
    of_person(person).limit(20)
  end

  def self.friends(person)
    of_person(person.user.friends).limit(20)
  end

  def self.hot(person)
    order_by_hot.limit(20)
  end

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

  def self.add_follower(topic_id, person)
    followship = ItemTopicFollowship.new(:item_topic_id => topic_id, :person_id => person.id)
    followship.save
  end

  def self.remove_follower(topic_id, person)
    ItemTopicFollowship.destroy_all(:item_topic_id => topic_id, :person_id => person.id)
  end

end
