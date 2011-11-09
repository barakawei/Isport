class HomeController < ApplicationController
  before_filter :registrations_closed?
  before_filter :authenticate_user!
  respond_to :js,:html

  def index
    if current_user
      auth = current_user.authorizations.first
      if (auth && auth.bind_status == Authorization::NOT_BINDED)
        redirect_to account_bind_path
        return
      end

      if (current_user.getting_started == true)
        redirect_to getting_started_path
        return
      end
      @hot_topics = ItemTopic.recent_random_topics
      @changeable = (@hot_topics.size == 5) 
      @events = Event.recent_events(current_user.profile.location.city)
      @is_binded = !auth.nil?
      
      @person = current_user.person
      #@requests_count = Request.where( :recipient_id => @person.id ).count
      @friends = current_user.friends
      @followed_people = current_user.followed_people
      @befollowed_people = current_user.befollowed_people
      @item_topic = ItemTopic.new 
      @active_items = @person.interests.most_discussed.limit(5) 
      @recent_topics = @person.item_topics.order('created_at desc').limit(8)
      #@post = Post.where( :author_id => current_user.person.id,:type => 'StatusMessage' ).order( "posts.created_at DESC" ).limit( 1 )
      @select_tab = 'home'
      @potential_friends = Person.potential_interested_people_limit(current_user.person)

      if current_user.last_new_item_notice_at < current_user.current_sign_in_at
        @notice_items = Item.where('created_at > ?',  current_user.last_sign_in_at) - @person.interests 
      end
    end
  end

  def show_post
    followed_people = current_user.followed_people
    people_id = followed_people.map{|p| p.id} + [current_user.person.id]
    followed_itemtopic_ids = current_user.person.concern_itemtopics.map{|i| i.id}
    followed_item_ids = current_user.person.interests.map{ |i| i.id}
    @posts = Post.where("author_id in(?) or item_topic_id in (?) or item_id in (?)",people_id,followed_itemtopic_ids,followed_item_ids).where( "type='StatusMessage'" ).includes( :comments ).includes( :author ).order( "posts.created_at DESC" ).paginate(:page => params[:page], :per_page => 20)
    @event_tab = 'post'
    @post_filter = 'all_post'
    respond_with @posts
  end

  def show_following_post
    followed_people = current_user.followed_people
    people_id = followed_people.map{|p| p.id} + [current_user.person.id]
    followed_itemtopic_ids = current_user.person.concern_itemtopics.map{|i| i.id}
    followed_item_ids = current_user.person.interests.map{ |i| i.id}
    @posts = Post.where("author_id = ? or item_topic_id in (?) or item_id in (?)",current_user.person.id,followed_itemtopic_ids,followed_item_ids).where( "type='StatusMessage'" ).includes( :comments ).includes( :author ).order( "posts.created_at DESC" ).paginate(:page => params[:page], :per_page => 20)
    @event_tab = 'post'
    @post_filter = 'following_post'
    render 'show_post'
  end

  def show_event
    @events = Event.at_city( current_user.city ).where("status = ? or (status != ? and events.person_id = ?) ",Event::PASSED,Event::PASSED,current_user.person.id).order( "events.start_at DESC" ).paginate(:page => params[:page], :per_page => 20)
    @event_tab = 'recent_event'
    respond_with @events
  end

  def show_following_event
    following_people = current_user.followed_people
    @events = Event.select( 'DISTINCT events.id,events.*' ).joins( :involvements).where( :person_id => following_people ).where("status = ? or (status != ? and events.person_id = ?) ",Event::PASSED,Event::PASSED,current_user.person.id).order( "events.start_at DESC" ).paginate(:page => params[:page], :per_page => 20)
    @event_tab = 'following_event'
    render 'show_event'
  end

  def show_my_event
    @events = current_user.person.involved_events.order( "events.start_at DESC" ).where("status = ? or (status != ? and events.person_id = ?) ",Event::PASSED,Event::PASSED,current_user.person.id).paginate(:page => params[:page], :per_page => 20)
    @event_tab = 'my_event'
    render 'show_event'
  end

  def show_event_details
    @event = Event.find( params[ :id ] )
  end
end
