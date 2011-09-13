module PicCommentsHelper
  def pic_image_link( pic )
    link_to (image_tag pic.url(:thumb_medium),:desc => pic.description,:id => pic.id,:class => 'stream-photo', 'data-small-photo' => pic.url(:thumb_small), 'data-full-photo' => pic.url( :thumb_large )), "#", :class => 'stream-photo-link'
  end
    
end
