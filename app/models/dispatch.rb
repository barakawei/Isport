class Dispatch
  require File.join(Rails.root, 'app/jobs/started_sharing_job.rb')
  require File.join(Rails.root, 'app/jobs/notify_user_job.rb')
  require File.join(Rails.root, 'app/jobs/dispatch_status_message_job.rb')


  def initialize(user, object,action=false)
    @sender = user
    @action = action
    @sender_person = @sender.person
    @object = object
    @subscribers = @object.subscribers(@sender,@action)
  end 
  
  def notify_user
    Resque.enqueue(Job::NotifyUserJob, @subscribers.map{|u| u.id}, @object.class.to_s, @object.id, @sender.id,@action)
  end

  def started_sharing
    Resque.enqueue(Job::StartedSharingJob,@sender.id,@object.recipient.user.id) 
    Notification.notify(@object.recipient, @object,@sender,@action )
  end

  def dispatch_status_message
    contact_ids =  @subscribers.map{ |p| p.user_id }
    Resque.enqueue(Job::DispatchStatusMessageJob,@object.id,contact_ids)
  end


end
  
