class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :getting_started,:invitation_service,:invitation_identifier,:last_request_at
  
  has_one :person
  has_many :contacts
  has_one :profile, :through => :person
  has_many :invitations_from_me, :class_name => 'Invitation', :foreign_key => :sender_id, :dependent => :destroy
  has_many :invitations_to_me, :class_name => 'Invitation', :foreign_key => :recipient_id, :dependent => :destroy
  has_many :friends, :through => :contacts, :source => :person, :conditions => "receiving=true"
  has_many :followed_people, :through => :contacts, :source => :person,:conditions => "receiving=true"
  has_many :befollowed_people, :through => :contacts, :source => :person,:conditions => "sharing=true"
  
  delegate :name,:to => :person
  delegate :location,:to => :profile

  has_many :authorizations do
    def find_or_create_by_params(params)
      provider, uid = params[:provider], params[:uid] 
      access_token, access_token_secret = params[:access_token], params[:access_token_secret]
      authorization = find_or_create_by_provider_and_uid(provider, uid) 
      authorization.update_attributes(params.except(:provider,:uid))
    end
  end


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

  def contact_for(person)
        return nil unless person
        contact_for_person_id(person.id)
  end

  def contact_for_person_id(person_id)
        Contact.where(:user_id => self.id, :person_id => person_id).first if person_id
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
    contact_user = self.contacts.find_or_initialize_by_person_id(person.id)
    unless contact_user.receiving?
      contact_user.receiving = true
    end
    contact_user.save
    contact_user
  end

  def remove_person( person ) 
    begin
      contact_user = self.contacts.where( :person_id => person.id ).first
      if contact_user && contact_user.receiving == true
        if !contact_user.mutual?
          contact_user.destroy
        else
          contact_user.update_attributes(:receiving => false)
        end
        contact_person = Contact.where( :user_id =>person.user.id , :person_id => self.person.id).first
        if contact_person
          if !contact_person.mutual?
            contact_person.destroy
          else
            contact_person.update_attributes(:sharing => false)
          end
        end 
      end 
      remove_unread_notify(self.person,person.user.id)
    end
  end

  def remove_unread_notify(target,recipient_id)  
    note_type = target.notification_type
    notify = note_type.where( :target_id => target.id,:recipient_id => recipient_id ).first 
    if notify && notify.unread == 1 
      notify.destroy
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
        self.invitation_token = nil
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
