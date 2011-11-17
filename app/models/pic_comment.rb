class PicComment < ActiveRecord::Base
  belongs_to :pic
  belongs_to :author,:foreign_key => :person_id,:class_name => "Person"

  after_save :update_owner_counter
  after_destroy :update_owner_counter
  after_update :update_owner_counter
  after_destroy :delete_notification
  has_one :notification_actor, :dependent => :destroy,:as => :target

  def delete_notification
    Notification.where(:target_type => self.class.name, :target_id => self.id).delete_all
  end

  def update_owner_counter
    self.pic.comments_count = self.pic.comments.count
    self.pic.save
  end 

  def dispatch_pic_comment(user=self.author.user)
    Dispatch.new(user, self).notify_user
  end

  def subscribers(user,action=false)
    [self.pic.author]
  end

  def notification_type( action=false )
    Notifications::PicComment
  end
end
