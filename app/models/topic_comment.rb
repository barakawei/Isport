class TopicComment < ActiveRecord::Base
  has_many :responses, :class_name => "TopicComment", 
                       :as => :commentable, :dependent => :destroy 
  
  belongs_to :commentable, :polymorphic => true 
  belongs_to :person

  def dispatch_topic_comment(user=person.user)
    Dispatch.new(user, self).notify_user
  end

  def subscribers(user,action=false)
    [self.commentable.person]
  end

  def notification_type( action=false )
    Notifications::TopicComment
  end
end
