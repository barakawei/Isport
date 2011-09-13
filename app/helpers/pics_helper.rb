module PicsHelper
  def get_imageable_des(album) 
    if album.imageable_type == 'Event'
      return I18n.t('events.pics') 
    end
  end

  
  def get_album_desc(album) 
    if album.imageable_type == 'Event'
      return I18n.t('events.pics_album', :name => album.imageable.name) 
    end
  end

  def get_imageable_path(album) 
    if album.imageable_type == 'Event'
      return event_path(album.imageable) 
    end
  end
  
end
