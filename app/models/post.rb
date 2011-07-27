class Post < ActiveRecord::Base
  belongs_to :author, :class_name => 'Person'
  has_many :post_visibilities
  has_many :contacts, :through => :post_visibilities
  has_many :comments

  def subscribers(user,action)
    user.followed_people
  end
  
  def dispatch_post( action=false )
    Dispatch.new(self.author.user, self,action).dispatch_status_message
  end

  def last_three_comments
    self.comments.order('created_at DESC').limit(3).includes(:author => :profile).reverse
  end 
  
  
  def as_json(opts={})
    {
        :post => {
          :id     => self.id
        }
    }
  end  
  

end
