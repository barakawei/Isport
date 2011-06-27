class Post < ActiveRecord::Base
  belongs_to :author, :class_name => 'Person'
  has_many :post_visibilities
  has_many :contacts, :through => :post_visibilities

  def subscribers(user)
    user.followed_people
  end
  
  def dispatch_post
    Dispatch.new(self.author.user, self).dispatch_status_message
  end
  
  def as_json(opts={})
    {
        :post => {
          :id     => self.id
        }
    }
  end  
  

end
