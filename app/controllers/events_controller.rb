#encoding: utf-8
require 'geocoder'
class EventsController < ApplicationController
  before_filter :authenticate_user!, 
                :except => [:index, :show, :show_participants, 
                            :show_references, :paginate_participants,
                            :paginate_references, :filtered]

  LIMIT = 12

  def index
    city_pinyin = params[:city] ? params[:city] : (current_user ? current_user.city.pinyin : City.first.pinyin)
    @city = City.find_by_pinyin(city_pinyin)
    @events = Event.all
    @hot_events = Event.hot_event(@city.id)
    @hot_items = Item.all
  end

  def my_events
    @type = params[:type]
    @events = []
    @removable = (@type == "joined" || @type == "recommended") 
    @events = current_user.send(@type)
  end

  def invite_friends
    @event = Event.find(params[:id])
    @invitees =  @event.invitees
    @invitees_size = size = @invitees.size
    @to_be_invited_friends = current_user.friends - @invitees
    @invitees.slice!(9, @invitees.length)
    @step = 2
    render :action => "new" 
  end

  def show
    @page = params[:page] ? params[:page].to_i : 1
    @event = Event.find(params[:id])
    @participants = @event.participants_top(LIMIT)
    @references = @event.references_top(LIMIT)
    @comments = []
    if @event.comments.size > 0
      @comments = @event.comments.paginate :page => params[:page],
                                           :per_page => 15, :order => 'created_at'

    end
    new_comment
  end

  def map
    @event = Event.find(params[:id])
  end

  def new
    @step = 1 
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
    if @event.save
      redirect_to new_event_invite_path(@event)
    else
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

  def show_participants
    get_participants
  end

  def show_references
    get_references
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
    @events = Event.filter_event(conditions).paginate :page => params[:page], :per_page => 15
  end
  
  private

  def get_participants
    @event = Event.find(params[:id])
    @participants =  @event.participants.order("created_at ASC")
    @friends = current_user ? current_user.friends : []
    @friend_participants = @participants & @friends
    @other_participants = @participants - @friend_participants  
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
