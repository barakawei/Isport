class Message < ActiveRecord::Base

  belongs_to :person
  belongs_to :conversation, :touch => true
  
  after_create do

  end
  def after_receive(user, person)
    if vis = ConversationVisibility.where(:conversation_id => self.conversation_id, :person_id => user.person.id).first
      vis.unread += 1
      vis.save
      self
    else
      raise NotVisibleException("Attempting to access a ConversationVisibility that does not exist!")
    end
  end
  
end
