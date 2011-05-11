class ContactsController < ApplicationController
  def new
    @person = Person.find(params[:person_id])
    @contact = request_to_person(@person)
    @contact && @contact.persisted?
    redirect_to :back
  end

  def request_to_person(person)
    request = current_user.send_contact_request_to(person)
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
