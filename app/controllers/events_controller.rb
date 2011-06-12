class EventsController < ApplicationController
  before_filter :authenticate_user!, :except => [:index, :show ]

  LIMIT = 12
  PER_PAGE = 32 

  def index
    @events = Event.all
    @selected = "events"
    @events.each do |event|
      event.same_day = (event.start_at.beginning_of_day == event.end_at.beginning_of_day)
      event.current_year = (event.start_at.year == Time.now.year)
    end
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @events }
    end
  end

  def show
    @event = Event.find(params[:id])
    @participants = @event.participants.order("created_at DESC").limit(LIMIT)
    @references = @event.references.order("created_at DESC").limit(LIMIT)

    if current_user
      @person = current_user.person
      @comment = Comment.new(:person_id => @person.id,
                             :item_id => @event.id)
      @comment.type = "EventComment"
    end

    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @event }
    end
  end

  def new
    @event = Event.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @event }
    end
  end

  def edit
    @event = Event.find(params[:id])
  end

  def create
    @event = Event.new(params[:event])
    @event.person = current_user.person
    respond_to do |format|
      if @event.save
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
    
    redirect_to(event_url(@event))
  end

  def remove_participant
    @event = Event.find(params[:id])
    @event.participants.delete(current_user.person)
    
    redirect_to(event_url(@event))
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

  def paginate_references
    get_references 
    
    references_used = params[:friend_page] != nil ? @paged_friend_references : @paged_other_references
    pagination_type = params[:friend_page] != nil ? "friend_page" : "other_page"

    render '_event_references', :layout => false,
                                :locals => { :references => references_used,
                                             :perline => 8, :pagination_type => pagination_type }
  end
  
  private
  
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
end
