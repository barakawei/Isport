class StatusMessage < Post
  has_many :pics, :dependent => :destroy

  attr_accessible :content


  def self.initialize( user,params = {} )
    status_message = StatusMessage.new
    status_message.author = user.person
    status_message.content = params[ :content ]
    status_message
  end

end



