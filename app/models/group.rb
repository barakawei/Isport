class Group < ActiveRecord::Base
  belongs_to :item
  belongs_to :city
  belongs_to :person


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

  def self.update_avatar_urls(params,url_params)
      group = find(params[:photo][:model_id])
      group.update_attributes(url_params)
  end

  private
  def default_url(size)
     case size
        when :thumb_medium then "/images/group/group_medium.jpg"
        when :thumb_large   then "/images/group/group_large.jpg"
        when :thumb_small   then "/images/group/group_small.jpg"
     end
  end
end
