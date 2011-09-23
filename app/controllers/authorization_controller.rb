class AuthorizationController < ApplicationController
  def oauth_create
    oauth = Weibo::OAuth.new(Weibo::Config.api_key, Weibo::Config.api_secret)
    request_token = oauth.authorize_from_request(session[:rtoken], session[:rsecret], params[:oauth_verifier])
    session[:rtoken], session[:rsecret] = nil, nil
    oauth.authorize_from_access(oauth.access_token.token, oauth.access_token.secret)
    auth_info = Weibo::Base.new(oauth).verify_credentials
    provider = 'sina' 
    user_auth  = Authorization.where(:uid => auth_info.id, :provider => provider).first
    if current_user
      @user = current_user
      if user_auth
        redirect_to bind_error_path 
        return
      else
        @auth =  @user.authorizations.find_or_create_by_params({
            :provider => provider, 
            :uid => auth_info.id,
            :access_token => oauth.access_token.token,
            :access_token_secret => oauth.access_token.secret,
            :bind_status => Authorization::BINDED
        })
      end
      redirect_to set_account_path 
    else
      if user_auth 
        @user = user_auth.user 
      else
        @weibo_user = Authorization.get_user_details(oauth.access_token.token, oauth.access_token.secret)
        count = User.count 
        @user = User.build(:email => "user#{count+1}@haoxiangwan.net", 
                           :password => '3275315321',
                           :password_confirmation => '3275315321' )
        name = @weibo_user.name
        location_info = @weibo_user.location
        city_name = location_info.split(' ')[1];
        city  = City.find_by_name(city_name)
        city_id = city ? city.id : 1 
        location = Location.create(:city_id => city_id)
        if @user.save
          @user.profile.name = name
          if @weibo_user.gender == 'm'
            @user.profile.gender = 1 
          else
            @user.profile.gender = 0 
          end

          @user.profile.location = location 
          @user.profile.save
          @user.authorizations.find_or_create_by_params({
            :provider => provider, 
            :uid => @weibo_user.id,
            :access_token => oauth.access_token.token,
            :access_token_secret => oauth.access_token.secret,
            :bind_status => Authorization::NOT_BINDED
          })
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
    email = params[:email]
    password = params[:password] 
    @user = current_user
    @authorization = @user.authorizations.first
    @user.update_attributes(:email => email)
    if  @user.update_with_password(:current_password => '3275315321',
                                   :password => password,
                                   :password_confirmation => password)
      sign_in(@user, :bypass => true)
      @authorization.update_attributes(:bind_status => Authorization::BINDED)
      redirect_to root_path      
    else
      auth = current_user.authorizations.first
      @weibo_user = Authorization.get_user_details(auth.access_token, auth.access_token_secret) 
      render 'bind_account'
    end
  end

  def bind_old_account
    @bind_new = false 
    email = params[:old_email]
    password = params[:old_password] 
    @user= User.find_by_email(email)
    @current_user = current_user
    unless @user 
      @user = User.new
      @user.errors[:email] = I18n.t('activerecord.errors.messages.not_found') 
      auth = current_user.authorizations.first
      @weibo_user = Authorization.get_user_details(auth.access_token, auth.access_token_secret) 
      render 'bind_account'
      return
    end

    unless @user.valid_password?(password)
      @user.errors[:password] = I18n.t('activerecord.errors.messages.password_wrong')
      auth = current_user.authorizations.first
      @weibo_user = Authorization.get_user_details(auth.access_token, auth.access_token_secret) 
      render 'bind_account'
      return 
    end
    @current_user.authorizations.first.update_attributes(:user_id => @user.id, :bind_status => Authorization::BINDED)  
    sign_out @current_user
    sign_in_and_redirect(:user, @user) 
  end

  def skip_bind
    @current_user = current_user  
    @auth = @current_user.authorizations.first 
    @auth.update_attributes(:bind_status => Authorization::SKIP_BINDING) if @auth.bind_status = Authorization::NOT_BINDED
    redirect_to root_path
  end
end
