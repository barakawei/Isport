class Notification < ActiveRecord::Base
  belongs_to :recipient, :class_name => 'User'
  has_many :notification_actors,:dependent => :destroy
  has_many :actor, :class_name => 'Person', :through => :notification_actors, :source => :person
  belongs_to :target, :polymorphic => true   


  def self.notify(recipient, target, actor,action=false)
    if target.respond_to? :notification_type
      note_type = target.notification_type( action )
      if target.instance_of?(Comment)
        target = target.post
      elsif target.instance_of?(Mention)
        target = target.post
      end
      note_type.make_notification(recipient, target, actor, note_type)
    end
  end

private
  def self.make_notification(recipient, target, actor, notification_type)
    notify = notification_type.where(:target_id => target.id,:recipient_id => recipient.id ).first
    if notify.nil? 
      n = notification_type.new(:target => target,:recipient_id => recipient.id)
      n.actor << actor
      n.save!
    else
      na = NotificationActor.where( :notification_id => notify,:person_id => actor ).first
      if na.nil?
        notify.actor << actor
      end
      notify.unread = notify.unread + 1
      notify.save!
    end
  end
end
