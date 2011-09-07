class ContactsController < ApplicationController
  before_filter :registrations_closed?
  before_filter :authenticate_user!
  respond_to :js,:html
  def create
    @person = Person.find(params[:person_id])
    contact = current_user.share_with(@person)
    contact.dispatch_request 
    respond_with @person
  end

  def show_avatar_panel
    @person = Person.where( :id=>params[ :person_id ] ).first
    if @person.id == current_user.person.id
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
    @person = Person.find(params[:person_id])
    current_user.remove_person( @person )
    respond_with @person
  end
end
