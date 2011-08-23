class Forum < ActiveRecord::Base
  belongs_to :discussable, :polymorphic => true

  has_many :topics, :dependent => :destroy

end
