class Contact < ActiveRecord::Base
  default_scope where(:pending => false)
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
  
  def dispatch_request( action=false )
    request = self.generate_request
    Dispatch.new(self.user, request,action).started_sharing
  end

  def generate_request
    Request.new(:sender => self.user.person,:recipient => self.person)
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
