class TopicComment < ActiveRecord::Base
  has_many :responses, :class_name => "TopicComment", 
                       :as => :commentable, :dependent => :destroy 
  
  belongs_to :commentable, :polymorphic => true 
  belongs_to :person
end
