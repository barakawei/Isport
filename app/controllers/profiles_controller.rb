class ProfilesController < ApplicationController
  def update
    params[:profile] ||= {}
    params[:profile][:photo] = Photo.where(:author_id => current_user.person.id,
                                           :id => params[:photo_id]).first if params[:photo_id]
    if current_user.profile.update_attributes(params[:profile])
      current_user.update_attributes(:getting_started=>false)
      redirect_to root_path
    end
  end   
  
end
