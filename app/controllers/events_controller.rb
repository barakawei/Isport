#encoding: utf-8
require 'geocoder'
class EventsController < ApplicationController
  before_filter :registrations_closed?
  before_filter :authenticate_user!,
                :except => [:index, :show, :participants, 
                            :references, :paginate_participants,
                            :paginate_references, :filtered, :map]
  before_filter :check_canceled,
                :only => [:edit, :edit_members, :update]                 

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
    @event_owner = @event.person
    @audit_person = @event.audit_person
    @is_owner = @event.is_owner(current_user) 
    if @event.in_audit_process? && !@is_owner && !current_user.try(:admin?)
      render 'common/in_audit', :locals => {:type => I18n.t('events_link'), 
              :link_content => I18n.t('events.other_events'), :path => events_path}
    end
    @participants = @event.participants_top(LIMIT)
    @par_ids = @event.participants.map{ |p|p.id }
    @references = @event.references_top(LIMIT)
    @current_person = current_user ? current_user.person : nil
    @comments = []
    if @event.comments_count> 0
      @comments = @event.comments.paginate :page => params[:page],
                                           :per_page => 8, :order => 'created_at'

    end
    new_comment
  end

  def map
    @event = Event.find(params[:id])
  end

  def home_map
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
    @items = Item.find(:all, :select => 'id, name')
    @new = true if params[:new] == 'new'
  end

  def edit_members
    @participants = (@event.participants.order("created_at ASC") || [ ]) 
    @participants -= [current_user.person] 
    @friends = (current_user.friends || [ ])
    @friend_participants = @participants & @friends
    @other_participants = @participants - @friend_participants  
    @invitees = (@event.invitees.order("created_at ASC") || [ ])
    render :action => :edit
  end

  def apply_reaudit
    @event= Event.find(params[:id])
    if @event.status == Event::DENIED && @event.is_owner(current_user)
      @event.update_attributes(:status => Group::BEING_REVIEWED, :status_msg => "");
    end
    redirect_to :back
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
  
  def cancel
    @event = Event.find(params[:id])
    unless @event.status == Event::CANCELED_BY_EVENT_ADMIN && @event.is_owner(current_user) 
      @event.update_attributes(:status => Event::CANCELED_BY_EVENT_ADMIN, :status_msg => params[:reason])
    end
    redirect_to event_path(@event)
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

  def check_canceled 
    @event = Event.find(params[:id])
    if @event.status == Event::CANCELED_BY_EVENT_ADMIN 
      redirect_to event_path(@event) 
    end
  end

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
