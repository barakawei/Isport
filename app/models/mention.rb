class Mention < ActiveRecord::Base
  belongs_to :post
  belongs_to :person
  validates :post, :presence => true
  validates :person, :presence => true
  after_destroy :delete_notification


  def subscribers(user,action=false)
    [self.person]
  end

  def notification_type( action=false )
    Notifications::Mention
  end

  def dispatch_mention(action=false)
    Dispatch.new(self.post.author.user, self,action).notify_user
  end

  def delete_notification
    Notification.where(:target_type => self.class.name, :target_id => self.id).delete_all
  end
  
end
