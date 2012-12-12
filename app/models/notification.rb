class Notification < ActiveRecord::Base
  belongs_to :recipient, :class_name => 'User'
  has_many :notification_actors,:dependent => :destroy
  has_many :actor, :class_name => 'Person', :through => :notification_actors, :source => :person,:order => "notification_actors.created_at DESC"
  belongs_to :target, :polymorphic => true   


  def self.notify(recipient, target, actor,action=false)
    if target.respond_to? :notification_type
      raw_target = target
      note_type = target.notification_type( action )
      if target.instance_of?(Comment)
        target = target.post
      elsif target.instance_of?(Mention)
        if target.post.nil?
          target = target.comment.post
        else
          target = target.post
        end
      elsif target.instance_of?( PicComment )
        target = target.pic
      elsif target.instance_of?( EventComment )
        target = target.commentable
      end
      note_type.make_notification(recipient, target, actor, note_type,raw_target)
    end
  end

private
  def self.make_notification(recipient, target, actor, notification_type,raw_target)
    notify = notification_type.where(:target_id => target.id,:recipient_id => recipient.id ).first
    if notify.nil? 
      n = notification_type.new(:target => target,:recipient_id => recipient.id)
      na = NotificationActor.new( :target => raw_target,:person => actor )
      n.notification_actors << na
      n.unread = 1
      n.save!
    else
      na = NotificationActor.where( :notification_id => notify,:person_id => actor ).first
      if na.nil?
        na_new = NotificationActor.new( :target => raw_target,:person => actor )
        notify.notification_actors << na_new
      else
        na.unread =  na.unread + 1
        na.save!
      end
      notify.unread = notify.unread + 1
      notify.save!
    end
  end
end
