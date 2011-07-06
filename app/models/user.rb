class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :getting_started
  has_one :person
  delegate :name,:to => :person
  has_many :contacts
  has_one :profile, :through => :person
  has_many :friends, :through => :contacts, :source => :person, :conditions => "pending='false'"

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
  
  def send_contact_request_to(desired_contact,message)
        contact = Contact.new(:person => desired_contact,
                              :user => self,
                              :pending => true)
        if contact.save!
          request = contact.dispatch_request( message )
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

  def update_profile(params)
    if photo = params.delete(:photo)
      photo.update_attributes(:pending => false) if photo.pending
      params[:image_url] = photo.url(:thumb_large)
      params[:image_url_medium] = photo.url(:thumb_medium)
      params[:image_url_small] = photo.url(:thumb_small)
    end
    if self.person.profile.update_attributes(params)
      true
    else
      false
    end
  end
  
  def joined
    person.involved_events
  end

  def recommended
    person.recommended_events
  end

  def friend_joined
    events = []
    friends.each do |friend|
      events += friend.involved_events
    end
    events
  end

  def friend_recommended
    events = []
    friends.each do |friend|
      events += friend.recommended_events
    end
    events
  end

  def city 
    profile.location.city
  end

end
