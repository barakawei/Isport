class RegistrationsController < Devise::RegistrationsController
  before_filter :check_registrations_open!
  def create
    @user = User.build( params[:user] )
    if @user.save
      Album.find_or_create_by_imageable_id_and_name(:imageable_id =>@user.person.id,:name => 'status_message',:imageable_type =>'Person')
      Album.find_or_create_by_imageable_id_and_name(:imageable_id =>@user.person.id,:name => 'avatar',:imageable_type =>'Person')
      sign_in_and_redirect(:user,@user)
    else
      render :action => :new
    end
  end

  def new
    super
  end

  def oauth_new
  end

  private
  def check_registrations_open!
    if AppConfig[:registrations_closed]
      flash[:error] = t('registrations.closed')
      redirect_to new_user_session_path
    end
  end
  
end
