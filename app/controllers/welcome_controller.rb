class WelcomeController < ApplicationController
  def index
    if current_user
      redirect_to home_path
    elsif AppConfig[:registrations_closed]
      redirect_to sign_in_path
    else
      @registe_wizard = true
      @citycount = City.count
      @usercount = User.count
      @groupcount = Group.count
      @eventcount = Event.count
      @events = Event.order('created_at desc').limit(3)
      @groups = Group.order('created_at desc').limit(3)
      @people = Person.limit(40)

      render
    end
  end

end
