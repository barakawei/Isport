module PicCommentsHelper
  def pic_image_link(pic, size=:thumb_medium)
    link_to (image_tag pic.url(size),:desc => pic.description,:id => pic.id,:class => 'stream-photo', 'data-small-photo' => pic.url(:shortcut_medium), 'data-full-photo' => pic.url( :thumb_large )), "#", :class => 'stream-photo-link'
  end
    
end
