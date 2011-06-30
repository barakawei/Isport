class HomeController < ApplicationController
  before_filter :authenticate_user!
  respond_to :js
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
      @posts = Post.joins( :contacts ).where( :contacts => {:user_id => current_user.id} )
      @selected = "home"
      render
    end
  end

  def show_post
    @posts = Post.joins( :contacts ).where( :contacts => {:user_id => current_user.id} )
    respond_with @posts
    
  end

  def show_event
  end
end
