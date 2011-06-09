class Item < ActiveRecord::Base
  validates :name, :presence => true
  validates :description, :presence => true

  def image_url(size = :thumb_large)
    result = if size == :thumb_medium && self[:image_url_medium]
       self[:image_url_medium]
     elsif size == :thumb_small && self[:image_url_small]
       self[:image_url_small]
     else
       self[:image_url_large]
     end
    result || default_url(size)
  end
  
  def image_url_large= url
    return image_url if url == ''
    if url.nil? || url.match(/^https?:\/\//)
      super(url)
    else
    end
  end

  def image_url_small= url
    return image_url if url == ''
    if url.nil? || url.match(/^https?:\/\//)
      super(url)
    else
    end
  end

  def image_url_medium= url
    return image_url if url == ''
    if url.nil? || url.match(/^https?:\/\//)
      super(url)
    else
    end
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
