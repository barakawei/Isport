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

  def self.hot_items(size, user)
    items = [  ]

    if user == nil
      items = self.joins(:events).where(:events => {:start_at => (Time.now.beginning_of_week)..(Time.now.end_of_week)})
        .group(:subject_id).order("count(subject_id) DESC").limit(size)

      if items.length < size
        items = self.joins(:events).where(:events => {:start_at => (Time.now.beginning_of_month)..(Time.now.end_of_month)})
          .group(:subject_id).order("count(subject_id) DESC").limit(size)
      end
    else
      city = City.find_by_pinyin(user.city.pinyin)
      items = self.joins(:events).joins(:events => [:location])
        .where(:events => {:start_at => (Time.now.beginning_of_week)..(Time.now.end_of_week),
                           :locations => {:city_id => city.id}})
        .group(:subject_id).order("count(subject_id) DESC").limit(size)

      if items.length < size
        items = self.joins(:events).joins(:events => [:location])
         .where(:events => {:start_at => (Time.now.beginning_of_month)..(Time.now.end_of_month), 
                            :locations => {:city_id => city.id}})
         .group(:subject_id).order("count(subject_id) DESC").limit(size)
      end
    end
    
    return items
  end

end
