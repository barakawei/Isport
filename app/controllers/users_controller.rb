class UsersController < ApplicationController
  def getting_started
    @user = current_user
    @person = @user.person
    @profile = @user.profile
    render "users/getting_started"
  end
end
