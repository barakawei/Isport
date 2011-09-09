class UsersController < ApplicationController
  before_filter :registrations_closed?
  before_filter :authenticate_user!, :except => [:new, :create, :public]
  before_filter :is_admin,:only => :online_user
  
  def getting_started
    if (current_user.getting_started == false)
        redirect_to home_path
        return
    end
    @registe_wizard = true
    @user = current_user
    @person = @user.person
    @profile = @user.profile
    @profile.location = Location.new
    render "users/getting_started"
  end


  def edit
    @user = current_user
    @profile = @user.profile
    render "users/getting_started"
  end

  def select_interests
    if (current_user.getting_started == false)
        redirect_to home_path
        return
    end
    @registe_wizard = true
    @items = Item.all
    @my_items = current_user.person.interests
    @items.each do |item|
      item.selected = true if @my_items.include?(item)
    end
  end

  def select_interested_people
    if (current_user.getting_started == false)
        redirect_to home_path
        return
    end
    @registe_wizard = true
    current_user.update_attributes(:getting_started => false)
    group = Group.where(:id => 2)
    group.first.members << current_user.person if group.size > 0
  end

  def change_password
    render 'devise/passwords/change_password.html.haml' 
  end

  def update_password
    @user = current_user
    if @user.update_with_password(params)
      sign_in(@user, :bypass => true)
      redirect_to root_path, :notice => "Password updated!"
    else
      render 'devise/passwords/change_password.html.haml' 
    end
  end

  def online_user
   @online_user = Person.joins(:user).joins( :profile ).where(["last_request_at > ?", 5.minutes.ago]).where("location_id is not null").paginate(:page => params[:page], :per_page => 100)
  end
  
end
