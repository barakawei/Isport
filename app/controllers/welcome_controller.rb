class WelcomeController < ApplicationController
  def index
    if current_user
      redirect_to home_path
    else
      @registe_wizard = true
      @citycount = City.count
      @usercount = User.count
      @groupcount = Group.count
      @eventcount = Event.count
      @events = Event.order('created_at desc').limit(3)
      @groups = Group.order('created_at desc').limit(3)

      render
    end
  end

end
