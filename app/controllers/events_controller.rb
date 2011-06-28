class EventsController < ApplicationController
  before_filter :authenticate_user!, :except => [:index, :show ]
  TIME_FILTER_TODAY = "today"
  TIME_FILTER_WEEK = "week"
  TIME_FILTER_WEEKENDS = "weekends"
  TIME_FILTER_ALL = "alltime"

  LIMIT = 12
  PER_PAGE = 32 

  def index
    get_filters   
    user_favorites_item_events
    @hottest_events = hottest_event
    @events = Event.order("start_at asc")
    @time_filter_path = TIME_FILTER_WEEK
    get_my_events
    process_event_time
    filte_by_popularity
  end

  def events_today
    @time_filter_path = TIME_FILTER_TODAY
    get_filters   
    user_favorites_item_events("today")
    @events = (@item_filter == nil) ? Event.today.order("start_at asc")
                                    : Item.find(@item_filter).events.today.order("start_at asc")
    get_my_events
    process_event_time
    filte_by_popularity
    render :action => "index"
  end

  def events_in_this_week
    get_filters   
    user_favorites_item_events("week")
    @events = (@item_filter == nil) ? Event.this_week.order("start_at asc")
                                    : Item.find(@item_filter).events.this_week.order("start_at asc")
    @time_filter_path = TIME_FILTER_WEEK
    get_my_events
    process_event_time
    filte_by_popularity
    render :action => "index"
  end

  def events_at_date_selected
    date = params[:date].to_date
    user_favorites_item_events(date.to_s)
    @events = (@item_filter == nil) ? Event.on_date(date).order("start_at asc")
                                    : Item.find(@item_filter).events.on_date(date).order("start_at asc")
    get_my_events
    process_event_time
    filte_by_popularity
    @time_filter_path = date.to_s 
    render :action => "index"
  end

  def my_events
    @type = params[:type]
    @events = []
    @removable = false
    case @type
    when "joined"
      @events = current_user.person.involved_events
      @removable = true
    when "recommended"
      @events = current_user.person.recommended_events
      @removable = true
    when "friend_joined"
      current_user.friends.each do |friend|
        @events += friend.involved_events
      end
    when "friend_recommended"
      current_user.friends.each do |friend|
        @events += friend.recommended_events
      end
    else
    end
  end

  def events_at_weekends
    get_filters   
    user_favorites_item_events("weekends")
    @events = (@item_filter == nil) ? Event.weekends.order("start_at asc")
                                    : Item.find(@item_filter).events.weekends.order("start_at asc")
    @time_filter_path = TIME_FILTER_WEEKENDS
    get_my_events
    process_event_time
    filte_by_popularity
    render :action => "index"
  end

  def events_all_time
    get_filters   
    user_favorites_item_events("alltime")
    @events = (@item_filter == nil) ? Event.order("start_at asc")
                                    : Item.find(@item_filter).events.order("start_at asc")
    @time_filter_path = TIME_FILTER_ALL
    get_my_events
    process_event_time
    filte_by_popularity
    render :action => "index"
  end

  def show
    @event = Event.find(params[:id])
    @participants = @event.participants.order("created_at DESC").limit(LIMIT)
    @references = @event.references.order("created_at DESC").limit(LIMIT)
    @comments = @event.paginated_comments(params[:page])

    new_comment
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @event }
    end
  end

  def new
    @event = Event.new
    @items = Item.find(:all, :select => 'id, name')
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @event }
    end
  end

  def edit
    @event = Event.find(params[:id])
    @items = Item.find(:all, :select => 'id, name')
    if params[:target] == "members"
      @participants = (@event.participants.order("created_at ASC") || [ ]) 
      @friends = current_user.friends
      @friend_participants = @participants & @friends
      @other_participants = @participants - @friend_participants  
    end
  end

  def create
    @event = Event.new(params[:event])
    @event.person = current_user.person
    respond_to do |format|
      if @event.save
        @event.dispatch_event( :create )
        format.html { redirect_to(@event, :notice => 'Event was successfully created.') }
        format.xml  { render :xml => @event, :status => :created, :location => @event }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @event.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @event = Event.find(params[:id])

    respond_to do |format|
      if @event.update_attributes(params[:event])
        format.html { redirect_to(@event, :notice => 'Event was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @event.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /events/1
  # DELETE /events/1.xml
  def destroy
    @event = Event.find(params[:id])
    @event.destroy

    respond_to do |format|
      format.html { redirect_to(events_url) }
      format.xml  { head :ok }
    end
  end

  def add_participant
    @event = Event.find(params[:id])
    @event.participants << current_user.person

    redirect_to :back
  end

  def remove_participant
    @event = Event.find(params[:id])
    @event.participants.delete(current_user.person)
    
    redirect_to :back
  end
  
  def show_participants
    get_participants
  end

  def show_references
    get_references
  end

  
  
  def paginate_participants
    get_participants
      
    participants_used = params[:friend_page] != nil ? @paged_friend_participants : @paged_other_participants    
    pagination_type = params[:friend_page] != nil ? "friend_page" : "other_page"

    render '_event_participants', :layout => false,
                                    :locals  =>  {:participants => participants_used, 
                                                  :perline => 8, :pagination_type => pagination_type } 
  end

  def paginate_comments
    @event = Event.find(params[:id])
    @comments = @event.paginated_comments(params[:page])

    new_comment
    render  "_event_comments",  :layout => false, :locals => { :event => @event,
                                                   :author=> @person,
                                               :comments => @comments,
                                               :comment => @comment}
  end

  def paginate_references
    get_references 
    
    references_used = params[:friend_page] != nil ? @paged_friend_references : @paged_other_references
    pagination_type = params[:friend_page] != nil ? "friend_page" : "other_page"

    render '_event_references', :layout => false,
                                :locals => { :references => references_used,
                                             :perline => 8, :pagination_type => pagination_type }
  end

  
  private

  def get_filters
    @item_filter = params[:id]
    @date_filter = params[:date]  
    @sort_filter = params[:sort]
  end 

  def filte_by_popularity
    if @sort_filter == "by_popularity"
      @events.sort! { |x,y| y.participants.size <=> x.participants.size }  
    end
  end

  def process_event_time
    @events.each do |event|
      event.same_day = (event.start_at.beginning_of_day == event.end_at.beginning_of_day)
      event.current_year = (event.start_at.year == Time.now.year) 
    end
  end
  
  def get_participants
    @event = Event.find(params[:id])
    @participants =  @event.participants.order("created_at ASC")
    @friends = current_user.friends
    @friend_participants = @participants & @friends
    @other_participants = @participants - @friend_participants  
    @paged_friend_participants = @friend_participants.paginate(:page => params[:friend_page], 
                                                               :per_page => PER_PAGE)
    @paged_other_participants = @other_participants.paginate(:page => params[:other_page], 
                                                               :per_page => PER_PAGE)
  end

  def get_references
    @event = Event.find(params[:id]) 
    @references = @event.references.order("created_at ASC")
    @friends = current_user.friends
    @friend_references = @references & @friends
    @other_references = @references - @friend_references
    @paged_friend_references = @friend_references.paginate(:page => params[:friend_page],
                                                           :per_page => PER_PAGE) 
    @paged_other_references = @other_references.paginate(:page => params[:other_page],

                                                           :per_page => PER_PAGE) 
  end

  def new_comment
      if current_user
        @person = current_user.person
        @comment = Comment.new(:person_id => @person.id,
                               :item_id => @event.id)
        @comment.type = "EventComment"
      end
  end

  def hottest_event
    hottest_event = Event.find(:all, :joins=>" INNER JOIN involvements on events.id = involvements.event_id",
               :select => "events.*, count(*) count",
               :group => 'involvements.event_id',
               :order => 'count desc',
               :limit => 3)

  end

  def user_favorites_item_events(time_filter_path="week")
    if current_user
      @favorite_items = current_user.person.interests.limit(5)   
      @item_event_size = [] 
      case time_filter_path
      when "today"
        @favorite_items.each {|item| @item_event_size << item.events.today.size }
      when "week" 
        @favorite_items.each  {|item| @item_event_size << item.events.this_week.size }
      when "weekends" 
        @favorite_items.each  {|item| @item_event_size << item.events.weekends.size }
      when "alltime" 
        @favorite_items.each  {|item| @item_event_size << item.events.size }
      else
        date = time_filter_path.to_date
        @favorite_items.each  {|item| @item_event_size << item.events.on_date(date).size }
      end  
    end
  end

  def get_my_events
    if current_user
      @joined_events = current_user.person.involved_events
      @recommended_events = current_user.person.recommended_events
      @friend_joined_events = []
      @friend_recommended_events = []
      current_user.friends.each do |friend|
        @friend_joined_events += friend.involved_events
        @friend_recommended_events += friend.recommended_events
      end
    end
  end

end
