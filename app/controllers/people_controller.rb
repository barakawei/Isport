class PeopleController < ApplicationController
  before_filter :authenticate_user!
  respond_to :js,:html

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
    @selected = "friends"
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
    contacts = {}
    Contact.unscoped.where(:user_id => current_user.id, :person_id => ids).each do |contact|
      contacts[contact.person_id] = contact
    end

    people.map{|p|
      {:person => p,
        :contact => contacts[p.id],
    }}
  end

  def show
    @person = Person.where(:id => params[:id]).first
    if @person
      @contact =  Contact.unscoped.where( :user_id => current_user.id ,:person_id => @person.id).first
      @friends = @person.user.friends
      @followed_people = @person.user.followed_people
      @befollowed_people = @person.user.befollowed_people
      @favorite_items = Item.joins( :favorites ).where( :favorites => {:person_id => @person.id })
      @events_inv = Event.joins(:involvements).where(:involvements => { :person_id => @person.id }  )
    end
  end

  def show_posts
    @posts = Post.where( :author_id => params[ :person_id ],:type => 'StatusMessage' ).order( "posts.created_at DESC" ).paginate(:page => params[:page], :per_page => 10)
    
    respond_with @posts
  end
  
  def edit_profile
    @person = Person.find( params[ :person_id ] )
    @profile = @person.profile
    respond_with @profile
  end

  def show_person_events
    person = Person.find( params[ :person_id ] )
    @events = person.involved_events.paginate(:page => params[:page], :per_page => 5)
    respond_with @events
  end

  def show_person_profile
    person = Person.find( params[ :person_id ] )
    @profile = person.profile
    respond_with @profile
  end

  def friend_select
    @friends = current_user.friends
    respond_to do |format|
      format.json{ render(:layout => false , :json => {"success" => true, "data" => @friends}.to_json )}
    end
  end

  def event_invitees_select
    event = Event.find(params[:id]) 
    @left_invitees = current_user.friends - event.invitees_plus_participants 
    respond_to do |format|
      format.json { render(:layout => false, :json => {"success" => true, "data" => @left_invitees}.to_json) }
    end
  end

  def group_invitees_select
    group = Group.find(params[:id]) 
    @left_invitees = current_user.friends - group.invitees_plus_members
    respond_to do |format|
      format.json { render(:layout => false, :json => {"success" => true, "data" => @left_invitees}.to_json) }
    end
  end
end


