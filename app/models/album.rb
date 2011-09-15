class Album < ActiveRecord::Base
  belongs_to :imageable, :polymorphic => true
  has_many :pics, :order => :position

end
