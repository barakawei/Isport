class Pic < ActiveRecord::Base
  require 'carrierwave/orm/activerecord'
  mount_uploader :unprocessed_image,UnprocessedImageUploader
  mount_uploader :processed_image,ProcessedAlbumpicUploader
  mount_uploader :avatar_processed_image,ProcessedImageUploader


  after_update :update_owner_counter
  after_destroy :update_owner_counter

  belongs_to :album
  belongs_to :status_message
  belongs_to :author, :class_name => 'Person'
  has_many :pic_comments, :dependent => :destroy
  has_many :comments, :class_name => 'PicComment',:dependent => :destroy
  attr_accessor :pic_type

  def pic_avatar?
    if self.pic_type == "avatar" || self.album.name == "avatar"
      true
    else
      false
    end
  end

  def not_processed?
    if self.pic_type == "avatar" || self.album.name == "avatar"
      avatar_processed_image.path.nil?
    else
      processed_image.path.nil?
    end
  end

  def processed?
    if self.pic_type == "avatar" || self.album.name == "avatar"
      !avatar_processed_image.path.nil?
    else
      !processed_image.path.nil?
    end
  end

  def self.initialize(params = {}, ip, port,person)
    photo = Pic.new
    image_file = params[ :user_file] 
    photo.random_string = ActiveSupport::SecureRandom.hex(10) 
    photo.unprocessed_image.store!( image_file )
    photo.update_remote_path(ip,port)
    photo.author = person
    photo
  end

  def update_remote_path(ip, port)
    remote_path = self.unprocessed_image.url
    name_start = remote_path.rindex '/'
    self.remote_photo_path = "#{remote_path.slice(0, name_start)}/"
    self.remote_photo_name = remote_path.slice(name_start + 1, remote_path.length)
  end

  def update_albums(person,params={})
    if self.pic_type === 'event'
      event = Event.find(params[:id])
      event.albums.first.pics << self
    else
      person.albums.where( :name => self.pic_type ).first.pics << self
    end
  end

  def url(size=:thumb_small)
    name = size.to_s 
    if processed?
      if self.pic_type == "avatar" || self.album.name == "avatar"
        avatar_processed_image.url(name)
      else
        processed_image.url(name)
      end
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
    if self.pic_type == "avatar" || self.album.name == "avatar"
      avatar_processed_image.store!(unprocessed_image) 
    else
      processed_image.store!(unprocessed_image) 
    end
    save!
  end

  def as_json(opts={})
    {
      :photo => {
        :id => self.id,
        :url => self.origin_url,
        :thumb_small => self.url(:thumb_small),
        :thumb_medium => self.url(:thumb_medium ),
        :thumb_large => self.url(:thumb_large ),
        :content => self.description
      }
    }
  end 

  def update_owner_counter
    self.album.pics_count = self.album.pics.count
    self.album.save
  end

end
