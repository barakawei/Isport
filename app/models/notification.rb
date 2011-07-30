class Notification < ActiveRecord::Base
  belongs_to :recipient, :class_name => 'User'
  has_one :notification_actor
  has_one :actor, :class_name => 'Person', :through => :notification_actor, :source => :person
  belongs_to :target, :polymorphic => true   


  def self.notify(recipient, target, actor,action=false)
    if target.respond_to? :notification_type
      note_type = target.notification_type( action )
      n = note_type.make_notification(recipient, target, actor, note_type)
      n
    end
  end

private
  def self.make_notification(recipient, target, actor, notification_type)
    n = notification_type.new(:target => target,:recipient_id => recipient.id)
    n.actor = actor
    n.save!
    n
  end

end
