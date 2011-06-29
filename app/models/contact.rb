class Contact < ActiveRecord::Base
  default_scope where(:pending => false)
  belongs_to :user
  belongs_to :person
  
  def dispatch_request( message )
    request = self.generate_request( message )
    request
  end

  def generate_request( message )
    Request.new(:message => message,:sender => self.user.person,:recipient => self.person)
  end 
  
end
