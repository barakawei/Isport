class RegistrationsController < Devise::RegistrationsController
  before_filter :check_registrations_open!
  def create
    @user = User.build( params[:user] )
    if @user.save
      sign_in_and_redirect(:user,@user)
    else
      render :action => :new
    end
  end

  def new
    super
  end

  private
  def check_registrations_open!
    if AppConfig[:registrations_closed]
      flash[:error] = t('registrations.closed')
      redirect_to new_user_session_path
    end
  end
  
end
