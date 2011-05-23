class PeopleController < ApplicationController
  before_filter :authenticate_user!,:except =>[:show]
  respond_to :html

  def index
    params[:q] ||= params[:term]
    if params[:q][0] == 35 || params[:q][0] == '#'
      redirect_to "/p/?tag=#{params[:q].gsub("#","")}"
      return
    end

    @people = Person.search(params[:q],current_user)
    @hashes = hashes_for_people(@people)
    respond_with @people
  end

  def show_friends
    @friends = current_user.friends
    render "people/friends_show"

  end

  def friends_request
    requests ={}
    sender_ids = []
    Request.where( :recipient_id => current_user.person.id ).each do |r|
      requests[ r.sender_id ] = r
      sender_ids.push( r.sender_id )
    end
    @people = []
    Person.where( :id => sender_ids ).each do |p|
      @people.push({:person => p,:request => requests[ p.id ] } )
    end
    render "people/friends_request"
  end

  def hashes_for_people people
    ids = people.map{|p| p.id}
    requests ={}
    Request.where(:sender_id => ids,:recipient_id => current_user.person.id).each do|r|
      requests[r.sender_id] = r
    end
    contacts = {}
    Contact.unscoped.where(:user_id => current_user.id, :person_id => ids).each do |contact|
      contacts[contact.person_id] = contact
    end

    people.map{|p|
      {:person => p,
        :contact => contacts[p.id],
        :request => requests[p.id]
    }}
  end

  def show
    @person = Person.where(:id => params[:id]).first
    if @person
      @contacts = Contact.where( :user_id => @person.user ).all 
    end
  end
end


