class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :getting_started
  has_one :person
  has_many :contacts
  has_one :profile, :through => :person

  def self.build( opts={} )
    u = User.new( opts )
    u.setup( opts)
    u
  end

  def setup( opts )
    opts[ :person ] = {  }
    opts[ :person ][ :profile ] = Profile.new
    self.person = Person.new( opts[ :person ] )
    self
  end
  
  def send_contact_request_to(desired_contact)
        contact = Contact.new(:person => desired_contact,
                              :user => self,
                              :pending => true)
        if contact.save!
          request = contact.dispatch_request
          request
        else
          nil
        end
  end

  def contact_for(person)
        return nil unless person
        contact_for_person_id(person.id)
  end

  def contact_for_person_id(person_id)
        Contact.unscoped.where(:user_id => self.id, :person_id => person_id).first if person_id
  end 
  
end
