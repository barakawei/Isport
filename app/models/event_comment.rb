class EventComment < ActiveRecord::Base
  belongs_to :commentable, :polymorphic => true
  belongs_to :person 

  has_many :responses, :class_name => "EventComment", :as => :commentable, :dependent => :destroy
end
