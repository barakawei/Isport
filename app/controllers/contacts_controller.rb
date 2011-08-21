class ContactsController < ApplicationController
  before_filter :registrations_closed?
  respond_to :js,:html
  def create
    @person = Person.find(params[:person_id])
    contact = current_user.share_with(@person)
    contact.dispatch_request 
    respond_with @person
  end

  def show_avatar_panel
    @person = Person.where( :id=>params[ :person_id ] )
    if @person.first.id == current_user.person.id
      json_data = {"myself" => true, "person" => @person,"contact" => []}.to_json
    else
      @contact = Contact.where( :user_id=>current_user.id,:person_id=>params[ :person_id ] )
      json_data = {"myself" => false, "person" => @person,"contact" => @contact}.to_json
    end
    respond_to do |format|
      format.json{ render(:layout => false , :json => json_data)}
    end
  end

  def destroy
    contact_user = Contact.where( :user_id => current_user.id, :person_id => params[ :person_id ] ).first
    if contact_user
      if !contact_user.mutual?
        contact_user.destroy
      else
        contact_user.update_attributes(:receiving => false)
      end
    end 
    contact_person = Contact.where( :user_id =>params[ :person_id ] , :person_id => current_user.id).first
    if contact_person
      if !contact_person.mutual?
        contact_person.destroy
      else
        contact_person.update_attributes(:sharing => false)
      end
    end 
    @person = Person.find(params[:person_id])
    respond_with @person
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
