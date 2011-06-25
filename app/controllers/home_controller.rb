class HomeController < ApplicationController
  before_filter :authenticate_user!
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
      @selected = "home"
      render
    end
  end
end
