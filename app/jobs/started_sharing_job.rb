module Job
  class StartedSharingJob
    @queue = :share
    require File.join(Rails.root, 'app/models/notification')
    def self.perform(recipient_id,sender_id)  
      RESQUE_LOGGER.info(Time.now.to_s+" @queue=:share,target_type=Person,action=follow,recipiend_id=#{recipient_id},sender_id=#{sender_id}")
      user = User.find_by_id( recipient_id )
      contact = user.contacts.find_or_initialize_by_person_id(sender_id)
      person = Person.find_by_id(sender_id)
      unless contact.sharing?
        contact.sharing= true
      end
      contact.save 
      Notification.notify(user,user.person,person)
    end
  end
end  

