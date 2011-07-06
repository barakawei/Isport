class ContactsController < ApplicationController
  def create
    @person = Person.find(params[:person_id])
    contact = current_user.share_with(@person)
    contact.dispatch_request 
    redirect_to :back
  end

  def destroy
    contact_user = Contact.where( :user_id => current_user.id, :person_id => params[ :person_id ] ).first
    if !contact_user.mutual?
      contact_user.destroy
    else
      contact_user.update_attributes(:receiving => false)
    end 
    contact_person = Contact.where( :user_id =>params[ :person_id ] , :person_id => current_user.id).first
    if !contact_person.mutual?
      contact_person.destroy
    else
      contact_person.update_attributes(:sharing => false)
    end 
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
