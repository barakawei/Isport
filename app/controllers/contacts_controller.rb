class ContactsController < ApplicationController
  def new
    if params[ :request ]
      person_id = params[ :request ][:person_id]
      message = params[ :request ][:message]
    else
      person_id = params[:person_id]
      message = ''
    end
    @person = Person.find(person_id)
    @contact = request_to_person(@person,message)
    @contact && @contact.persisted?
    redirect_to :back
  end

  def remove_friend 
    contact_user = Contact.where( :user_id => current_user.id, :person_id => params[ :person_id ] ).first
    contact_user.destroy
    contact_person = Contact.where( :user_id =>params[ :person_id ] , :person_id => current_user.id).first
    contact_person.destroy
    redirect_to :back
  end

  def request_to_person(person,message)
    request = current_user.send_contact_request_to(person,message)
    contact = current_user.contact_for(person)
    if r = Request.where(:sender_id => person.id,:recipient_id => current_user.person.id).first
      r.destroy
      c = Contact.unscoped.where(:user_id =>person.user_id,:person_id => current_user.person.id).first
      c.update_attributes(:pending => false) if c
      contact.update_attributes(:pending => false)
    else
      request.save
    end
    contact
  end
end
