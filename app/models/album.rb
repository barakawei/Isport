class Album < ActiveRecord::Base
  belongs_to :imageable, :polymorphic => true
  has_many :pics, :order => :position,:dependent => :destroy 
  scope :default_album,lambda { |album_name| where(:name => album_name) }

  def album_pics( person )
    self.pics.where( :author_id => person )
  end

  def can_delete?
    if self.name != "status_message" && self.name != "avatar"
      true
    else
      false
    end
  end

  def is_avatar?
    if self.name == "avatar"
      true
    else 
      false
    end
  end

end
