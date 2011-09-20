class AuthorizationController < ApplicationController
  def oauth_create
    auth = request.env["omniauth.auth"]
    user_auth  = Authorization.where(:uid => auth['uid'], :provider => auth['provider']).first
    if user_auth 
      @user = user_auth.user 
      sign_in_and_redirect(:user, @user) 
    else
      access_token = auth['credentials']['token']
      access_token_secret = auth['credentials']['secret']
      consumer = OAuth::Consumer.new('3275315321','672d08bd608a97e4adb23e8e81c215a0',{:site =>'http://api.t.sina.com.cn'})
      accesstoken = OAuth::AccessToken.new(consumer, access_token, access_token_secret)
      response = accesstoken.get("http://api.t.sina.com.cn/account/verify_credentials.json")
      @weibo_user = JSON.parse(response.body)
      count = User.count 
      @user = User.build(:email => "user#{count+1}@haoxiangwan.net", 
                         :password => '3275315321',
                         :password_confirmation => '3275315321' )
      name = @weibo_user['screen_name']
      location_info = @weibo_user['location']
      city_name = location_info.split(' ')[1];
      city  = City.find_by_name(city_name)
      city_id = city ? city.id : 1 
      location = Location.create(:city_id => city_id)
      if @user.save
        @user.profile.name = name
        if @weibo_user['gender'] == 'm'
          @user.profile.gender = 1 
        else
          @user.profile.gender = 0 
        end

        @user.profile.location = location 
        @user.profile.save
        @user.authorizations.find_or_create_by_params({
          :provider => auth['provider'], 
          :uid => auth['uid'],
          :access_token => auth['credentials']['token'],
          :access_token_secret => auth['credentials']['secret']
        })
        sign_in_and_redirect(:user, @user) 
      else
      end
    end
  end

  def oauth_destroy
  end

  def oauth_login
    auth = request.env["omniauth.auth"]
    if Authorization.where(:uid => auth[:uid], :provider => auth[:provider]).size > 0
      redirect_to root_path
    else
      redirect_to connect_to_weibo_path() 
    end
  end
end
