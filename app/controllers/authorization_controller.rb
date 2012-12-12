class AuthorizationController < ApplicationController
  def oauth_create
    oauth = Authorization.get_authorized_request(session[:rtoken], session[:rsecret], params[:oauth_verifier])   
    session[:rtoken], session[:rsecret] = nil, nil
    auth_info = Authorization.get_user_details_by_oauth(oauth)
    user_auth  = Authorization.where(:uid => auth_info.id, :provider => Authorization::P_SINA).first
    if current_user
      @user = current_user
      if user_auth
        redirect_to bind_error_path 
        return
      else
        @auth = @user.authorizations.find_or_create_by_params({:provider => Authorization::P_SINA, 
                                                               :uid => auth_info.id,
                                                               :access_token => oauth.access_token.token,
                                                               :access_token_secret => oauth.access_token.secret,
                                                               :bind_status => Authorization::BINDED})
      end
      redirect_to set_account_path 
    else
      if user_auth 
        @user = user_auth.user 
      else
        @weibo_user = Authorization.get_user_details(oauth.access_token.token, oauth.access_token.secret)
        @user = User.create_user_by_weibo(@weibo_user)
        unless @user.id.nil?
          @user.authorizations.find_or_create_by_params({:provider => Authorization::P_SINA, 
                                                         :uid => @weibo_user.id,
                                                         :access_token => oauth.access_token.token,
                                                         :access_token_secret => oauth.access_token.secret,
                                                         :bind_status => Authorization::NOT_BINDED})
        else
        end
      end
      sign_in_and_redirect(:user, @user) 
    end
  end

  def oauth_destroy
  end

  def connect 
    oauth = Weibo::OAuth.new(Weibo::Config.api_key, Weibo::Config.api_secret)
    request_token = oauth.consumer.get_request_token
    session[:rtoken], session[:rsecret] = request_token.token, request_token.secret

    redirect_to "#{request_token.authorize_url}&oauth_callback=http://#{request.env["HTTP_HOST"]}/auth/callback"
  end

  def bind_account
    @bind_new = true
    auth = current_user.authorizations.first
    @weibo_user = Authorization.get_user_details(auth.access_token, auth.access_token_secret) 
  end 

  def bind_new_account
    @bind_new = true
    @user = current_user
    @auth = @user.authorizations.first

    @user.update_attributes(:email => params[:email])
    if @user.update_with_password(:current_password => '3275315321',
                                  :password => params[:password],
                                  :password_confirmation => params[:password])
      sign_in(@user, :bypass => true)
      @auth.update_attributes(:bind_status => Authorization::BINDED)
      redirect_to root_path      
    else
      @weibo_user = Authorization.get_user_details(@auth.access_token, @auth.access_token_secret) 
      render 'bind_account'
    end
  end

  def bind_old_account
    @bind_new = false 
    @user= User.find_by_email(params[:old_email])
    @auth = current_user.authorizations.first

    unless @user 
      @user = User.new
      @user.errors[:email] = I18n.t('activerecord.errors.messages.not_found') 
      @weibo_user = Authorization.get_user_details(@auth.access_token, @auth.access_token_secret) 
      render 'bind_account'
      return
    end

    unless @user.valid_password?(params[:old_password])
      @user.errors[:password] = I18n.t('activerecord.errors.messages.password_wrong')
      @weibo_user = Authorization.get_user_details(@auth.access_token, @auth.access_token_secret) 
      render 'bind_account'
      return 
    end

    @auth.update_attributes(:user_id => @user.id, :bind_status => Authorization::BINDED)  
    sign_out current_user
    sign_in_and_redirect(:user, @user) 
  end

  def skip_bind
    @auth = current_user.authorizations.first
    @auth.update_attributes(:bind_status => Authorization::SKIP_BINDING) if @auth.bind_status = Authorization::NOT_BINDED
    redirect_to root_path
  end
end
