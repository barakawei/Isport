class EventPhotosControllerController < CommonPhotosControllerController 
  before_filter :registrations_closed?
  def setRelatedUrl(photo)
    event_avatar_url_params = {:image_url => photo.url(:thumb_large),
                               :image_url_medium => photo.url(:thumb_medium),
                               :image_url_small => photo.url(:thumb_small)}
    update_event(event_avatar_url_params)
  end

  private 

  def update_event(params)
  end

end
