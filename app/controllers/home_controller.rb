class HomeController < ApplicationController
  before_filter :registrations_closed?
  before_filter :authenticate_user!
  respond_to :js,:html

  def index
    if current_user
      auth = current_user.authorizations.first
      @is_binded = !auth.nil?
      if (auth && auth.bind_status == Authorization::NOT_BINDED)
        redirect_to account_bind_path
        return
      end

      if (current_user.getting_started == true)
        redirect_to getting_started_path
        return
      end
      
      @person = current_user.person
      #@requests_count = Request.where( :recipient_id => @person.id ).count
      @friends = current_user.friends
      @followed_people = current_user.followed_people
      @befollowed_people = current_user.befollowed_people
      @item_topic = ItemTopic.new 
      @recent_topics = @person.item_topics.order('created_at desc').limit(8)
      #@post = Post.where( :author_id => current_user.person.id,:type => 'StatusMessage' ).order( "posts.created_at DESC" ).limit( 1 )
      @select_tab = 'home'
      render
    end
  end

  def show_post
    @posts = Post.by_view( current_user.person ).order( "posts.created_at DESC" ).paginate(:page => params[:page], :per_page => 30)
    @event_tab = 'post'
    respond_with @posts
  end

  def show_event
    @events = Event.at_city( current_user.city ).where("status = ? or (status != ? and events.person_id = ?) ",Event::PASSED,Event::PASSED,current_user.person.id).order( "events.start_at DESC" ).paginate(:page => params[:page], :per_page => 30)
    @event_tab = 'recent_event'
    respond_with @events
  end

  def show_following_event
    following_people = current_user.followed_people
    @events = Event.select( 'DISTINCT events.id,events.*' ).joins( :involvements).where( :person_id => following_people ).where("status = ? or (status != ? and events.person_id = ?) ",Event::PASSED,Event::PASSED,current_user.person.id).order( "events.start_at DESC" ).paginate(:page => params[:page], :per_page => 30)
    @event_tab = 'following_event'
    render 'show_event'
  end

  def show_my_event
    @events = current_user.person.involved_events.order( "events.start_at DESC" ).where("status = ? or (status != ? and events.person_id = ?) ",Event::PASSED,Event::PASSED,current_user.person.id).paginate(:page => params[:page], :per_page => 30)
    @event_tab = 'my_event'
    render 'show_event'
  end

  def show_event_details
    @event = Event.find( params[ :id ] )
  end
end
