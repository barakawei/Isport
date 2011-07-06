module Job
  class StartedSharingJob
    @queue = :share
    def self.perform( sender_id, recipient_id)  
      user = User.find_by_id( recipient_id )
      contact = user.contacts.find_or_initialize_by_person_id(sender_id)
      contact.sharing = true
      contact.save 
    end
  end
end  

