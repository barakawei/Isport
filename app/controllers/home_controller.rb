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
      @post = Post.where( :author_id => current_user.person.id,:type => 'StatusMessage' ).order( "posts.created_at DESC" ).limit( 1 )
      render
    end
  end

  def show_post
    @posts = Post.select("distinct(posts.id),posts.*").joins( "left join post_visibilities pv on(posts.id = pv.post_id) left join contacts c on(pv.contact_id = c.id)" ).where( "posts.type='StatusMessage' and (author_id = #{current_user.id} or c.user_id = #{current_user.id})" ).order( "posts.created_at DESC" ).paginate(:page => params[:page], :per_page => 10)
    
    respond_with @posts
  end

  def show_event
    @events = Event.order( "created_at DESC" ).paginate(:page => params[:page], :per_page => 5)
    respond_with @events
  end

  def show_event_details
    @event = Event.find( params[ :id ] )
  end
end
