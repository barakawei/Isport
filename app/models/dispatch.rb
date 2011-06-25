class Dispatch
  require File.join(Rails.root, 'app/jobs/started_sharing.rb')
  require File.join(Rails.root, 'app/jobs/notify_user.rb')
  def initialize(user, object)
    @sender = user
    @sender_person = @sender.person
    @object = object
    @subscribers = @object.subscribers(@sender)
  end 
  
  def notify_user
    Resque.enqueue(Job::NotifyUser, @subscribers.map{|u| u.id}, @object.class.to_s, @object.id, @sender.id)
  end

  def started_sharing
    Resque.enqueue(Job::StartedSharing,@sender.id,@object.recipient.user.id) 
    Notification.notify(@sender, @object, @object.recipient)
  end
end
  

