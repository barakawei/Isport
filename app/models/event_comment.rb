class EventComment < ActiveRecord::Base
  after_create :update_owner_counter
  after_destroy :update_owner_counter
  after_update :update_owner_counter

  def update_owner_counter
    e = self.commentable
    e.update_attributes(:comments_count => e.comments.count) 
  end

  belongs_to :commentable, :polymorphic => true
  belongs_to :person 

  has_many :responses, :class_name => "EventComment", :as => :commentable, :dependent => :destroy
end
