class Album < ActiveRecord::Base
  belongs_to :imageable, :polymorphic => true
  has_many :pics, :order => :position

  def album_pics( person )
    self.pics.where( :author_id => person )
  end

end
