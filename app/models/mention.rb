class Mention < ActiveRecord::Base
  belongs_to :post
  belongs_to :person
  belongs_to :comment
  validates :person, :presence => true
  after_destroy :delete_notification
  has_one :notification_actor, :dependent => :destroy


  def subscribers(user,action=false)
    [self.person]
  end

  def notification_type( action=false )
    Notifications::Mention
  end

  def dispatch_mention(action=false)
    if self.post
      user = self.post.author.user
    else
      user =self.comment.author.user
    end
    Dispatch.new(user, self,action).notify_user
  end

  def delete_notification
    Notification.where(:target_type => self.class.name, :target_id => self.id).delete_all
  end
  
end
