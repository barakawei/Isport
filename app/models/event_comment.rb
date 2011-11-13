class EventComment < ActiveRecord::Base
  after_create :update_owner_counter
  after_destroy :update_owner_counter
  after_update :update_owner_counter
  belongs_to :commentable, :polymorphic => true
  belongs_to :person 
  belongs_to :author, :foreign_key => "person_id", :class_name => 'Person'
  has_many :responses, :class_name => "EventComment", :as => :commentable, :dependent => :destroy
  after_destroy :delete_notification

  def delete_notification
    Notification.where(:target_type => self.class.name, :target_id => self.id).delete_all
  end

  def update_owner_counter
    e = self.commentable
    if !e.instance_of?( Event )
      e = self.commentable.commentable
    end
    e.update_attributes(:comments_count => e.comments.count) 
  end

  def dispatch_event_comment(user=person.user)
    Dispatch.new(user, self).notify_user
  end

  def subscribers(user,action=false)
    self.commentable.relative_people
  end

  def notification_type( action=false )
    Notifications::EventComment
  end
end
