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
<<<<<<< HEAD
      @items = Item.order('rand()').limit(3)
      @events = Event.where(:id => 1...10).order('rand()').limit(3)
      @groups = Group.where(:id => 1...10).order('rand()').limit(3)
=======
      @events = Event.order('created_at desc').limit(3)
      @groups = Group.order('created_at desc').limit(3)
      @people = Person.limit(40)
>>>>>>> 19b59902e42f18c6d4dca4760914f2d5fd68e4df

      render
    end
  end

end
