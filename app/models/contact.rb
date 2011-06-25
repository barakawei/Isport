class Contact < ActiveRecord::Base
  default_scope where(:pending => false)
  belongs_to :user
  belongs_to :person
  
  scope :sharing, lambda {
    where(:sharing => true)
  }

  scope :receiving, lambda {
    where(:receiving => true)
  }
  
  
  def mutual?
    self.sharing && self.receiving
  end
  
  def dispatch_request
    request = self.generate_request
    Dispatch.new(self.user, request).started_sharing
  end

  def generate_request
    Request.new(:sender => self.user.person,:recipient => self.person)
  end 
  
end
