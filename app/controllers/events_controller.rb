#encoding: utf-8
require 'geocoder'
class EventsController < ApplicationController
  before_filter :registrations_closed?
  before_filter :authenticate_user!,
                :except => [:index, :show, :participants, 
                            :references, :paginate_participants,
                            :paginate_references, :filtered, :map]
                  

  LIMIT = 9 


  def index
    city_pinyin = params[:city] ? params[:city] : (current_user ? current_user.city.pinyin : City.first.pinyin)
    @city = City.find_by_pinyin(city_pinyin)
    @hot_events = current_user ? Event.interested_event(@city.id, current_user.person) : []
    @hot_items = current_user ? Item.hot_items(5, @city).all: []
    @select_tab = 'event'
  end

  def my_events
    @type = params[:type]
    @events = []
    @removable = false 
    @events = current_user.send(@type)
  end

  def invite_friends
    @event = Event.find(params[:id])
    @invitees =  @event.invitees
    @invitees_size = @invitees.size
    @to_be_invited_friends = current_user.friends - @invitees || []
    @invitees
    @step = 2
    @steps = [I18n.t('events.new_event_wizards.step_1'), I18n.t('events.new_event_wizards.step_2')]
    render :action => "new" 
  end

  def show
    @event = Event.find(params[:id])
    @participants = @event.participants_top(LIMIT)
    @references = @event.references_top(LIMIT)
    @current_person = current_user ? current_user.person : nil
    @comments = []
    @comments_size = @event.comments.size
    if @comments_size > 0
      @comments = @event.comments.paginate :page => params[:page],
                                           :per_page => 8, :order => 'created_at'

    end
    new_comment
  end

  def map
    @event = Event.find(params[:id])
  end

  def new
    @steps = [I18n.t('events.new_event_wizards.step_1'), I18n.t('events.new_event_wizards.step_2')]
    @step = 1 
    @event = Event.new
    @event.location = Location.new(:city_id => current_user.person.location.city.id, :district_id => 1, :detail => " ")
    unless params[:group_id].nil?
      @group = Group.find(params[:group_id])
      @event.group = @group
      @event.item = @group.item
      @event.location = Location.new(:city_id => @group.city_id, :district_id => @group.district_id)
    end
    @items = Item.find(:all, :select => 'id, name')
  end

  def edit
    @event = Event.find(params[:id])
    @items = Item.find(:all, :select => 'id, name')
    @new = true if params[:new] == 'new'
    puts GoogleGeoCoder.getLocation("南京")
  end

  def edit_members
    @event = Event.find(params[:id])
    @participants = (@event.participants.order("created_at ASC") || [ ]) 
    @participants -= [current_user.person] 
    @friends = (current_user.friends || [ ])
    @friend_participants = @participants & @friends
    @other_participants = @participants - @friend_participants  
    @invitees = (@event.invitees.order("created_at ASC") || [ ])
    render :action => :edit
  end

  def create
    @current_person = current_user.person 
    event_attrs = params[:event]
    location = Location.create(event_attrs[:location_attributes])
    l_info = GoogleGeoCoder.getLocation(location.to_s)
    event_attrs[:location_attributes].merge!(l_info) unless l_info.nil?
    @event = Event.new(event_attrs)
    @event.status_msg = 
    @event.person = @current_person 
    if @event.save
      Involvement.create(:event_id => @event.id, :person_id => @current_person)
      redirect_to new_event_invite_path(@event)
    else
      @step = 1
      @steps = [I18n.t('events.new_event_wizards.step_1'), I18n.t('events.new_event_wizards.step_2')]
      render :action => :new
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

  def participants
    get_participants
  end

  def references
    get_references
  end

  def filtered
    city_pinyin = params[:city] ? params[:city] : (current_user ? current_user.city.pinyin : City.first.pinyin)
    @city = City.find_by_pinyin(city_pinyin)
    @district_id = params[:district_id]
    @item_id = params[:item_id]
    @time = params[:time].nil? ?  'alltime' : params[:time] 
    @time_filter_str = (@time =~ /\d\d\d\d-\d\d-\d\d/) ? @time : I18n.t('filter.time.select_time')
       
    conditions = {:city_id => @city.id, :time => @time}
    conditions[:district_id] = @district_id unless @district_id.nil?
    conditions[:subject_id] = @item_id unless @item_id.nil?
    @events = Event.filter_event(conditions).paginate :page => params[:page], :per_page => 15
    @select_tab = 'event'
  end
  
  private

  def get_participants
    @event = Event.find(params[:id])
    @participants =  @event.participants.order("created_at ASC").paginate :page => params[:page],
                                                                          :per_page => 10
  end

  def get_references
    @event = Event.find(params[:id]) 
    @references = @event.references.order("created_at ASC")
    @friends = current_user ? current_user.friends : []
    @friend_references = @references & @friends
    @other_references = @references - @friend_references
  end

  def new_comment
      if current_user
        @person = current_user.person
        @comment = EventComment.new(:person_id => @person.id)
        @comment.commentable= @event 
      end
  end
end
