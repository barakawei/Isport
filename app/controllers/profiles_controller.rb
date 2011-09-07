class ProfilesController < ApplicationController
  before_filter :registrations_closed?
  before_filter :authenticate_user!
  def update
    params[:profile] ||= {}
    @profile = current_user.profile
    if @profile.update_attributes params[:profile]
      if params[ :profile_edit ] 
        redirect_to :back
      else
        redirect_to select_interests_path
      end
    else
      puts '8******&&&&&&&&'
      puts @profile.errors
      redirect_to :back
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
