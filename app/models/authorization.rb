class Authorization < ActiveRecord::Base
  NOT_BINDED = 0
  SKIP_BINDING = 1
  BINDED = 2
  CRLF = "\r\n"

  belongs_to :user
  
  validate :user_id, :uid, :provider, :presence => true
  validate :uid, :uniqueness => { :scope => :provider } 

  def self.get_user_details(access_token, access_token_secret)
    consumer = OAuth::Consumer.new('3275315321','672d08bd608a97e4adb23e8e81c215a0',{:site =>'http://api.t.sina.com.cn'})
    accesstoken = OAuth::AccessToken.new(consumer, access_token, access_token_secret)
    response = accesstoken.get("http://api.t.sina.com.cn/account/verify_credentials.json")
    JSON.parse(response.body)
  end

  def get_details
    consumer = OAuth::Consumer.new('3275315321','672d08bd608a97e4adb23e8e81c215a0',{:site =>'http://api.t.sina.com.cn'})
    accesstoken = OAuth::AccessToken.new(consumer, self.access_token, self.access_token_secret)
    response = accesstoken.get("http://api.t.sina.com.cn/account/verify_credentials.json")
    JSON.parse(response.body)
  end

  def create_weibo_with_photo(status, file)
    oauth = Weibo::OAuth.new(Weibo::Config.api_key, Weibo::Config.api_secret)
    oauth.authorize_from_access(self.access_token, self.access_token_secret)
    Weibo::Base.new(oauth).upload(status, file)
  end
end
