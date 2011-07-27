class ProfilesController < ApplicationController
  before_filter :authenticate_user!
  def update
    params[:profile] ||= {}
    if current_user.profile.update_attributes params[:profile]
      current_user.update_attributes(:getting_started=>false)
      if params[ :profile_edit ] 
        redirect_to :back
      else
        redirect_to root_path
      end
    end
  end   

  def update_profile
    profile = Profile.find( params[ :profile_id ] )
    name = params[ :id ]
    profile.update_attributes({ name => params[ :value ]})
    render {}
  end

  def index
    @profile = current_user.profile
    render
  end
end
