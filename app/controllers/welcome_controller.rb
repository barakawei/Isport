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
      @items = Item.order('rand()').limit(3)
      @events = Event.where(:id => 1...10).order('rand()').limit(3)
      @groups = Group.where(:id => 1...10).order('rand()').limit(3)
      @people = Person.limit(40)

      render
    end
  end

end
