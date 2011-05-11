class ContactsController < ApplicationController
  def new
    @person = Person.find(params[:person_id])
    @aspectors_with_person =[]
    @aspectors_without_person = current_user.aspectors
    @contact = Contact.new
    render :layout => false
  end

  def create
    @person = Person.find(params[:person_id])
    @aspector = current_user.aspectors.where(:id=>params[:aspector_id]).first
    @contact = request_to_aspector(@aspector,@person)

    if @contact && @contact.persisted?
      respond_to do |format|
        format.js{render :json=>{:button_html => render_to_string(:partial => 'aspector_memberships/add_to_aspector',:locals => {:aspector_id => @aspector.id,:person_id => @person.id}),:badge_html => render_to_string(:partial => 'aspectors/aspector_badge',:locals =>{:aspector => @aspector}),:conact_id => @contact.id}}
        format.html{redirect_to aspector_path(@aspector.id)}
      end
    else
      redirect_to :back
    end
  end

  def request_to_aspector(aspector,person)
    request = current_user.send_contact_request_to(person,aspector)
    contact = current_user.contact_for(person)
    if r = Request.where(:sender_id => person.id,:recipient_id => current_user.person.id).first
      r.destroy
      c = Contact.unscoped.where(:user_id =>person.owner_id,:person_id => current_user.person.id).first
      c.update_attributes(:pending => false) if c
      contact.update_attributes(:pending => false)
    else
      request.save
    end
    contact
  end
end
