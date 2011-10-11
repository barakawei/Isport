module PicsHelper
  def pic_image_link(pic, size=:thumb_medium)
    return if pic.nil?
    if pic.pic_avatar?
      url = pic.url( :thumb_large )
    else
      url = pic.url(size)
    end
    link_to (image_tag url,:desc => pic.description,:count =>pic.comments.size,:id => pic.id,:class => 'stream-photo', 'data-small-photo' => pic.url(:thumb_large), 'data-full-photo' => pic.url( :thumb_large )), "#", :class => 'stream-photo-link'
  end

  def pic_image_tag( pic,size=:thumb_medium )
    link = pic_image_link(pic,size)
    count = pic.comments.size
    pic_comment = ""
    if count > 0
      pic_comment = "<div class='pic_comment'><div class='count'>#{count}</div><div class='arrow'></div></div>"
    end
    "<div class='pic_element'>#{link.html_safe}#{pic_comment.html_safe}</div>".html_safe
  end

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
