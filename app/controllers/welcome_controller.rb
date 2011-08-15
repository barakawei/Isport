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

      render
    end
  end

end
