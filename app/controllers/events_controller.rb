#encoding: utf-8
require 'geocoder'
class EventsController < ApplicationController
  before_filter :authenticate_user!, 
                :except => [:index, :show, :show_participants, 
                            :show_references, :paginate_participants,
                            :paginate_comments, :paginate_references]

  TIME_FILTER_TODAY = "today"
  TIME_FILTER_WEEK = "week"
  TIME_FILTER_WEEKENDS = "weekends"
  TIME_FILTER_ALL = "alltime"

  LIMIT = 12
  PER_PAGE = 32 

  def index
    city_pinyin = params[:city] ? params[:city] : (current_user ? current_user.city.pinyin : City.first.pinyin)
    @city = City.find_by_pinyin(city_pinyin) 
    events_by_time_filter
    @hottest_events = hottest_event(@city.id) if params[:time].nil?
  end

  def my_events
    @type = params[:type]
    @events = []
    @removable = (@type == "joined" || @type == "recommended") 
    @events = current_user.send(@type)
  end

  def show
    @event = Event.find(params[:id])
    @participants = @event.participants_top(LIMIT)
    @references = @event.references_top(LIMIT)
    @comments = @event.paginated_comments(params[:page])

    new_comment
  end

  def map
    @event = Event.find(params[:id])
  end

  def new
    @event = Event.new
    @event.location = Location.new(:city_id => 1, :district_id => 1, :detail => " ")
    @items = Item.find(:all, :select => 'id, name')
  end

  def edit
    @event = Event.find(params[:id])
    @items = Item.find(:all, :select => 'id, name')
    puts GoogleGeoCoder.getLocation("南京")
  end

  def edit_members
    @event = Event.find(params[:id])
    @participants = (@event.participants.order("created_at ASC") || [ ]) 
    @friends = (current_user.friends || [ ])
    @friend_participants = @participants & @friends
    @other_participants = @participants - @friend_participants  
    @invitees = (@event.invitees.order("created_at ASC") || [ ])
    render :action => :edit
  end

  def create
    event_attrs = params[:event]
    location = Location.new(event_attrs[:location_attributes])
    l_info = GoogleGeoCoder.getLocation(location.to_s)
    event_attrs[:location_attributes].merge!(l_info) unless l_info.nil?
    @event = Event.new(event_attrs)
    @event.person = current_user.person
    unless @event.save
      render :action => "new" 
    else
      redirect_to event_members_path(@event)
    end
  end

  def update
    @event = Event.find(params[:id])
    event_attrs = params[:event]
    location = Location.new(event_attrs[:location_attributes])
    l_info = GoogleGeoCoder.getLocation(location.to_s)
    event_attrs[:location_attributes].merge!(l_info) unless l_info.nil?
    if @event.update_attributes(event_attrs)
      redirect_to event_path(@event)
    else
      render :action => "edit" 
    end
  end

  def destroy
    @event = Event.find(params[:id])
    @event.destroy
    redirect_to(events_url)
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
                                                  :perline => 8, :pagination_type => pagination_type,
                                                   :edit => false} 
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

  def filtered
    city_pinyin = params[:city] ? params[:city] : (current_user ? current_user.city.pinyin : City.first.pinyin)
    @city = City.find_by_pinyin(city_pinyin)
    @district_id = params[:district_id]
    @item_id = params[:item_id]
    @time = params[:time].nil? ?  'alltime' : params[:time] 
    conditions = {:city_id => @city.id, :time => @time}
    conditions[:district_id] = @district_id unless @district_id.nil?
    conditions[:subject_id] = @item_id unless @item_id.nil?
    @events = Event.filter_event(conditions).paginate :page => params[:page], :per_page => 10
  end
  
  private

  def events_by_time_filter
    get_filters   
    unless  @time_filter_path =~ /\d\d\d\d-\d\d-\d\d/
      @events = (@item_filter == nil) ? Event.send(@time_filter_path).at_city(@city.id).order("start_at asc")
                                        : Item.find(@item_filter).events.send(@time_filter_path).at_city(@city.id).order("start_at asc")
      user_favorites_item_events(@time_filter_path)
    else
      date = @time_filter_path.to_date
      user_favorites_item_events(date.to_s)
      @time_filter_path = date.to_s 
      @events = (@item_filter == nil) ? Event.on_date(date).order("start_at asc")
                                      : Item.find(@item_filter).events.on_date(date).at_city(@city.id).order("start_at asc")
    end 
    get_my_events
    process_event_time
    filte_by_popularity
  end

  def get_filters
    @time_filter_path = (params[:time].nil?) ? 
                        TIME_FILTER_ALL : params[:time] 
    @item_filter = params[:id]
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
    @friends = current_user ? current_user.friends : []
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
    @friends = current_user ? current_user.friends : []
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

  def hottest_event(city_id)
    hottest_event = Event.find(:all, 
               :conditions => [" locations.city_id = ? ", city_id],
               :joins=>" INNER JOIN involvements on events.id = involvements.event_id INNER JOIN locations on events.location_id = locations.id ",
               :select => "events.*, count(*) count",
               :group => 'involvements.event_id',
               :order => 'count desc',
               :limit => 3)
  end

  def user_favorites_item_events(time_filter_path="week")
    if current_user
      @favorite_items = current_user.person.interests.limit(5)   
      @item_event_size = [] 
      unless time_filter_path =~ /\d\d\d\d-\d\d-\d\d/
        @favorite_items.each {|item| @item_event_size << item.events.today.size }
      else
        date = time_filter_path.to_date
        @favorite_items.each  {|item| @item_event_size << item.events.on_date(date).size }
      end  
    end
  end

  def get_my_events
      @joined_events = current_user.joined
      @recommended_events = current_user.recommended
      @friend_joined_events = current_user.friend_joined 
      @friend_recommended_events = current_user.friend_recommended
  end
end
