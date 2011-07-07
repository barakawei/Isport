class HomeController < ApplicationController
  before_filter :authenticate_user!
  respond_to :js,:html
  def index
    if current_user
      if (current_user.getting_started == true)
        redirect_to getting_started_path
        return
      end
      @person = current_user.person
      @requests_count = Request.where( :recipient_id => @person.id ).count
      @friends = current_user.friends
      @followed_people = current_user.followed_people
      @befollowed_people = current_user.befollowed_people
      @current_status = Post.where(:author_id => @person.id ).order("created_at DESC" ).first

      @selected = "home"
      @hot_events = Event.joins("left join involvements inv on(events.id = inv.event_id) left join recommendations rec on(type = 'EvntRecommendation' and events.id = rec.item_id)").select( "events.*,count(inv.id) inv_counts,count(rec.id) rec_counts,count(inv.id)+count(rec.id) hots" ).group( "events.id" ).order( "hots DESC" ).limit(5)
      render
    end
  end

  def show_post
    @posts = Post.joins(:contacts ).where( :contacts => {:user_id => current_user.id},:type => "StatusMessage").order( "posts.created_at DESC" ).paginate(
      :page => params[:page], :per_page => 10)

    if params[ :page ] == nil
      @tab = "post"
    end
    respond_with @posts
    
  end

  def show_event
    @notifications = Notification.includes( :actor ).where( "recipient_id = ? and type != ?",current_user.id,"Notifications::InviteEvent").order( "notifications.created_at DESC" ).paginate(
      :page => params[:page], :per_page => 5)
    if params[ :page ] == nil
      @tab = "event"
    end
    respond_with @notifications
  end
end
