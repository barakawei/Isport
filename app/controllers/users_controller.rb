class UsersController < ApplicationController
  before_filter :authenticate_user!, :except => [:new, :create, :public]
  
  def getting_started
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
    @items = Item.all
    @my_items = current_user.person.interests
    @items.each do |item|
      item.selected = true if @my_items.include?(item)
    end
  end
end
