module Job
  class NotifyUserJob
    @queue = :notify

    require File.join(Rails.root, 'app/models/notification')

    def self.perform(user_ids, object_klass, object_id, person_id,action)
      RESQUE_LOGGER.info(Time.now.to_s+" @queue=:notify,target_type=#{object_klass},action=#{action},target_id=#{object_id},recipiend_ids=#{user_ids},sender_id=#{person_id}")
      users = User.where(:id => user_ids)
      object = object_klass.constantize.find_by_id(object_id)
      person = Person.find_by_id(person_id)
      users.find_each do |user| 
        Notification.notify(user, object, person,action)
      end
    end
  end
end 

