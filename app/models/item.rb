class Item < ActiveRecord::Base
  validates :name, :presence => true
  validates :description, :presence => true

  has_many :favorites, :dependent => :destroy
  has_many :fans, :through => :favorites, :source => :person

  has_many :events, :foreign_key => "subject_id" 
  has_many :groups, :foreign_key => "item_id"

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

  private

  def default_url(size)
     case size
        when :thumb_medium then "/images/event/event_medium.jpg"
        when :thumb_large   then "/images/event/event_large.jpg"
        when :thumb_small   then "/images/event/event_small.jpg"
     end
  end

end
