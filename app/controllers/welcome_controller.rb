class WelcomeController < ApplicationController
  def index
    if current_user
      redirect_to home_path
    elsif AppConfig[:registrations_closed]
      redirect_to sign_in_path
    else
      @registe_wizard = true
      @citycount = Location.count('city_id', :distinct => true)
      @usercount = User.count
      @groupcount = Group.count
      @eventcount = Event.count
      @items = Item.order('rand()').limit(3)
      @people = Person.selected_random
      @events = Event.pass_audit.selected_random
      @groups = Group.pass_audit.selected_random

      render
    end
  end

  def notice
    render :layout => false
  end

end
