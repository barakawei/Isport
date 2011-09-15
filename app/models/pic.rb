class Pic < ActiveRecord::Base
  require 'carrierwave/orm/activerecord'
  mount_uploader :processed_image,ProcessedAlbumpicUploader
  mount_uploader :unprocessed_image,UnprocessedImageUploader


  after_destroy :update_owner_counter
  after_update :update_owner_counter

  belongs_to :album
  belongs_to :status_message
  belongs_to :author, :class_name => 'Person'
  has_many :pic_comments
  has_many :comments, :class_name => 'PicComment'
  
  def not_processed?
    processed_image.path.nil?
  end

  def processed?
    !processed_image.path.nil?
  end

  def self.initialize(params = {}, ip, port,user)
    photo = Pic.new
    image_file = params[ :user_file] 
    photo.random_string = ActiveSupport::SecureRandom.hex(10) 
    photo.unprocessed_image.store!( image_file )
    photo.update_remote_path(ip,port)
    photo.author = user
    photo
  end

  def update_remote_path(ip, port)
    remote_path = self.unprocessed_image.url
    name_start = remote_path.rindex '/'
    self.remote_photo_path = "#{remote_path.slice(0, name_start)}/"
    self.remote_photo_name = remote_path.slice(name_start + 1, remote_path.length)
  end

  def update_albums(user,params = {})
    pic_type = params[ :pic_type ]
    if pic_type === 'event'
      event = Event.find(params[:id])
      event.albums.first.pics << self
    else
      user.person.albums.where( :name => pic_type ).first.pics << self
    end
  end

  def url(size=:thumb_small)
    name = size.to_s 
    if processed?
      processed_image.url(name)
    elsif not_processed?
      unprocessed_image.url
    elsif remote_photo_path
      name = name.to_s + '_' if name
      remote_photo_path + name.to_s + remote_photo_name
    end
  end

  def origin_url
    unprocessed_image.url
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
        :url => self.origin_url,
        :thumb_small => self.url,
        :thumb_medium => self.url(:thumb_medium),
        :content => self.description
      }
    }
  end 

  def update_owner_counter
    self.album.pics_count = self.album.pics.count
    self.album.save
  end

end
