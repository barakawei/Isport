module AlbumsHelper
  def album_image_link( album,person,size = :shortcut_medium )
    last_pic = album.album_pics( person ).order( "created_at DESC" ).first
    return if last_pic.nil?
    if album.name == "avatar"
      url = last_pic.url(:thumb_large)
    else
      url = last_pic.url(size)
    end

    link_to (image_tag url,:id => last_pic.id),person_album_path(person,album )
  end

  def album_image_tag( album,person,size = :shortcut_medium )
    last_pic = album.album_pics( person ).order( "created_at DESC" ).first
    return if last_pic.nil?
    if album.name == "avatar"
      url = last_pic.url(:thumb_large)
    else
      url = last_pic.url(size)
    end
    image_tag url,:id => last_pic.id
  end

  def album_name_tag( album )
    name = album.name
    if name == "status_message"
      t("albums.status_message")
    elsif name == "avatar"
      t("albums.avatar")
    elsif album.imageable.instance_of? Event
      album.imageable.title
    else
      album.name
    end
  end
end
