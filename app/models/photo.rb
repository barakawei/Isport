class Photo < Post
  require 'carrierwave/orm/activerecord'
  mount_uploader :processed_image,ProcessedImageUploader
  mount_uploader :unprocessed_image,UnprocessedImageUploader

  def not_processed?
    processed_image.path.nil?
  end

  def processed?
    !processed_image.path.nil?
  end

  def self.initialize(params = {})
    photo = Photo.new
    image_file = params[ :user_file] 
    photo.random_string = ActiveSupport::SecureRandom.hex(10) 
    photo.unprocessed_image.store!( image_file )
    photo.update_remote_path
    photo
  end

  def update_remote_path
    remote_path = "http://localhost:8888"+self.unprocessed_image.url
    name_start = remote_path.rindex '/'
    self.remote_photo_path = "#{remote_path.slice(0, name_start)}/"
    self.remote_photo_name = remote_path.slice(name_start + 1, remote_path.length)
  end
  
  def url(name = nil)
    if remote_photo_path
      name = name.to_s + '_' if name
      remote_photo_path + name.to_s + remote_photo_name
    elsif not_processed?
      unprocessed_image.url(name)
    else
      processed_image.url(name)
    end
  end

  def process
    return false if self.processed? || (!unprocessed_image.path.nil? && unprocessed_image.path.include?('.gif'))
    processed_image.store!(unprocessed_image) 
    save!
  end

  def as_json(opts={})
    {
    :photo => {
        :id => self.id,
        :url => self.url,
        :thumb_small => self.url(:thumb_small),
        :thumb_medium => self.url( :thumb_medium ),
        :thumb_large => self.url( :thumb_large ),
        :content => self.content
      }
    }
  end 
  

end
