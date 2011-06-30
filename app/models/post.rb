class Post < ActiveRecord::Base
  belongs_to :author, :class_name => 'Person'
  has_many :post_visibilities
  has_many :contacts, :through => :post_visibilities
  has_many :comments
  default_scope where(:type => "StatusMessage")

  def subscribers(user,action)
    user.followed_people
  end
  
  def dispatch_post( action=false )
    Dispatch.new(self.author.user, self,action).dispatch_status_message
  end
  
  def as_json(opts={})
    {
        :post => {
          :id     => self.id
        }
    }
  end  
  

end
