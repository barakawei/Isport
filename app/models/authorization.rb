class Authorization < ActiveRecord::Base
  NOT_BINDED = 0
  SKIP_BINDING = 1
  BINDED = 2
  CRLF = "\r\n"

  belongs_to :user
  
  validate :user_id, :uid, :provider, :presence => true
  validate :uid, :uniqueness => { :scope => :provider } 

  def self.get_user_details(access_token, access_token_secret)
    oauth = Weibo::OAuth.new(Weibo::Config.api_key, Weibo::Config.api_secret)
    oauth.authorize_from_access(access_token, access_token_secret)
    auth_info = Weibo::Base.new(oauth).verify_credentials
  end

  def get_details
    oauth = Weibo::OAuth.new(Weibo::Config.api_key, Weibo::Config.api_secret)
    oauth.authorize_from_access(self.access_token, self.access_token_secret)
    auth_info = Weibo::Base.new(oauth).verify_credentials
  end

  def create_weibo_with_photo(status, file)
    oauth = Weibo::OAuth.new(Weibo::Config.api_key, Weibo::Config.api_secret)
    oauth.authorize_from_access(self.access_token, self.access_token_secret)
    Weibo::Base.new(oauth).upload(status, file)
  end
end
