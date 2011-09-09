class PeopleController < ApplicationController
  before_filter :registrations_closed?
  before_filter :authenticate_user!
  respond_to :js,:html

  def index
    params[:q] ||= params[:term]
    if params[:q][0] == 35 || params[:q][0] == '#'
      redirect_to "/p/?tag=#{params[:q].gsub("#","")}"
      return
    end
    limit = params[:limit] ? params[:limit].to_i : 15 
    respond_to do |format|
      format.json do
        @people = Person.search(params[:q], current_user).limit(limit)
        render :json => @people
      end

      format.html do
        @people = Person.search(params[:q],current_user).paginate(:page => params[:page], :per_page => 35)
        @hashes = hashes_for_people(@people)
      end 
    end
  end

  def show_groups
    @person = Person.find( params[ :person_id ] )
    @groups = @person.joined_groups.paginate(:page => params[:page], :per_page => 20)
    @select_tab = 'groups_tab'  
    render "people/show_person_details"
  end

  def show_items
    @person = Person.find( params[ :person_id ] )
    @items= @person.interests.paginate(:page => params[:page], :per_page => 35)
    @select_tab = 'items_tab'  
    render "people/show_person_details"
  end

  def show_friends
    @type = params[ :type ]
    @person = Person.find( params[ :person_id ] )
    if @type == 'followed'
      @people = @person.user.followed_people.paginate(:page => params[:page], :per_page => 35)

      @select_tab = 'following_tab'  
    else
      @people = @person.user.befollowed_people.paginate(:page => params[:page], :per_page => 35)

      @select_tab = 'followers_tab'  
    end
    render "people/show_person_details"

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
    @person = Person.find(params[:id])

    @contact =  Contact.unscoped.where( :user_id => current_user.id ,:person_id => @person.id).first
    @friends = @person.user.friends
    @followed_people = @person.user.followed_people
    @befollowed_people = @person.user.befollowed_people
    @favorite_items = Item.joins( :favorites ).where( :favorites => {:person_id => @person.id })
    @events_inv = Event.joins(:involvements).where(:involvements => { :person_id => @person.id }  )
  end


  def show_posts
    @posts = Post.where( :author_id => params[ :person_id ],:type => 'StatusMessage' ).order( "posts.created_at DESC" ).paginate(:page => params[:page], :per_page => 10)
    @page = params[ :page ]
    respond_with @posts
  end
  
  def edit_profile
    @person = current_user.person
    @profile = @person.profile

    render
  end

  def show_person_events
    person = Person.find( params[ :person_id ] )
    if current_user.person.id == person.id
      @events = person.involved_events.order( "events.start_at DESC" ).paginate(:page => params[:page], :per_page => 10)
    else
      @events = person.involved_events.where("status = ? ",Event::PASSED).order( "events.start_at DESC" ).paginate(:page => params[:page], :per_page => 10)
    end
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

  def choose_interests
    item_ids = params[:item_ids].split(',');
    current_user.person.add_interests(item_ids)      
    render :nothing => true
  end

  def edit_interests
    @current_person = current_user.person
    @items = Item.all
    @my_items = current_user.person.interests
    @items.each do |item|
      item.selected = true if @my_items.include?(item)
    end
  end

  def random_item_fans
    item  = Item.find params[:item_id]
    city_pinyin = params[:city] ? params[:city] : (current_user ? current_user.city.pinyin : City.first.pinyin)
    city = City.find_by_pinyin(city_pinyin)

    @people = item.random_people(city, 6, current_user.followed_people+[current_user.person]) 
    render :partial => 'people/show_contacts', :locals => {:people => @people, :groups => nil, :items => nil}
  end
end


