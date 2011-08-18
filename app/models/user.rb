class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :getting_started,:invitation_service,:invitation_identifier
  has_one :person
  delegate :name,:to => :person
  has_many :contacts
  has_one :profile, :through => :person
  has_many :invitations_from_me, :class_name => 'Invitation', :foreign_key => :sender_id, :dependent => :destroy
  has_many :invitations_to_me, :class_name => 'Invitation', :foreign_key => :recipient_id, :dependent => :destroy
  has_many :friends, :through => :contacts, :source => :person, :conditions => "receiving=true"
  has_many :followed_people, :through => :contacts, :source => :person,:conditions => "receiving=true"
  has_many :befollowed_people, :through => :contacts, :source => :person,:conditions => "sharing=true"


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

  def share_with( person )
    contact = self.contacts.find_or_initialize_by_person_id(person.id)
    unless contact.receiving?
      contact.receiving = true
    end
    contact.save
    contact
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

  def invite_user(service, identifier, invite_message = "")
      Invitation.invite(:service => service,
                        :identifier => identifier,
                        :from => self,
                        :message => invite_message)
  end
  

  def accept_invitation!(opts = {})
    begin
      if self.invited?
        self.setup(opts)
        self.password = opts[:password]
        self.password_confirmation = opts[:password_confirmation]
        self.save!
        invitations_to_me.each{|invitation| invitation.share_with!} 
        self.reload # Because to_request adds a request and saves elsewhere
        self
      end
    end
  end

end
