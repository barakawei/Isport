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
      @events = Event.pass_audit.order('rand()').limit(3)
      @groups = Group.pass_audit.order('rand()').limit(3)

      @photos = [ ]
      numbers = Array.new(40).fill{|i| i+1}
      numbers.each do |n|
        @photos.push("/images/welcome/#{n}.jpg")
      end
      
      @photos.sort_by!{rand}
      render
    end
  end

  def notice
    render :layout => false
  end

end
