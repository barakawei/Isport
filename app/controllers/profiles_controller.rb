class ProfilesController < ApplicationController
  def update
    params[:profile] ||= {}
    if current_user.profile.update_attributes params[:profile]
      current_user.update_attributes(:getting_started=>false)
      redirect_to root_path
    end
  end   
end
