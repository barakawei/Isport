class Contact < ActiveRecord::Base
  belongs_to :user
  belongs_to :person
  has_many :post_visibilities
  has_many :posts, :through => :post_visibilities
  
  
  scope :sharing, lambda {
    where(:sharing => true)
  }

  scope :receiving, lambda {
    where(:receiving => true)
  }
  
  
  def mutual?
    self.sharing && self.receiving
  end

  def notification_type( action=false )
    Notifications::StartedSharing
  end

  def subscribers(user,action)
    [self.person]
  end
  
  def dispatch_request( action=false )
    Dispatch.new(self.user,self,action).started_sharing
  end

  def as_json(opts={})
    {
    :contact => {
        :id => self.id,
        :receiving => self.receiving,
        :sharing => self.sharing
      }
    }
  end 

  
end
