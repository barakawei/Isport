class RegistrationsController < Devise::RegistrationsController
  def create
    @user = User.build( params[:user] )
    if @user.save
      sign_in_and_redirect(:user,@user)
    else
      new_user_registration_url
    end
  end

  def new
    super
  end
end
