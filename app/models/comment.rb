class Comment < ActiveRecord::Base
  belongs_to :author,:foreign_key => :person_id,:class_name => "Person"
  belongs_to :post,:touch => true

  def dispatch_comment(user=self.author.user)
    Dispatch.new(user, self).notify_user
  end

  def subscribers(user,action=false)
    [self.post.author]
  end

  def notification_type( action=false )
    Notifications::StatusComment
  end
end
