class Contact < ActiveRecord::Base
  belongs_to :user
  belongs_to :person
  
  def dispatch_request
    request = self.generate_request
    request
  end

  def generate_request
    Request.new(:sender => self.user.person,:recipient => self.person)
  end 
  
end
