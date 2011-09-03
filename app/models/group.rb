class Group < ActiveRecord::Base
  JOIN_FREE = 1 
  JOIN_AFTER_AUTHENTICATAION = 2 
  JOIN_BY_INVITATION_FROM_ADMIM = 3 

  after_save :update_owner_counter
  after_destroy :update_owner_counter
  after_update :update_owner_counter

  belongs_to :item
  BEING_REVIEWED = 0
  DENIED = 1
  PASSED = 2
  CANCELED_BY_EVENT_ADMIN = 3

  belongs_to :city
  belongs_to :district
  belongs_to :person
  belongs_to :audit_person, :foreign_key => "audit_person_id", :class_name => 'Person'
  attr_accessor :invited_people

  validates_presence_of :name, :description, :item_id, :city_id, :district_id,
                        :join_mode,
                        :message => I18n.t('activerecord.errors.messages.blank')

  validates_length_of :name, :maximum => 30
  validates_length_of :description, :maximum => 3000 


  has_many :memberships, :dependent => :destroy

  has_many :events, :dependent => :destroy, 
                    :conditions => ["events.status = ?", Group::PASSED]
  has_many :invitees_plus_members, :through => :memberships, :source => :person

  has_many :members, :through => :memberships,  :source => :person,
                        :conditions => ['memberships.pending = ? ', false]

  has_many :invitees, :through => :memberships, :source => :person,
                        :conditions => ['memberships.pending = ? and memberships.pending_type = ? ', true, JOIN_BY_INVITATION_FROM_ADMIM] 
  
  has_many :applicants, :through => :memberships, :source => :person,
                        :conditions => ['memberships.pending = ? and memberships.pending_type = ? ', true,  JOIN_AFTER_AUTHENTICATAION] 

  has_many :deletable_members, :through => :memberships, :source => :person,
           :conditions => ['memberships.is_admin = ? and memberships.pending = ?', false, false] 
  has_many :related_person, :through => :memberships, :source => :person
  has_many :admins, :through => :memberships, :source => :person, 
                        :conditions => ['memberships.is_admin = ?', true]

  has_one :forum,  :as => :discussable, :dependent => :destroy
  has_many :topics, :through => :forum, :source => :topics

  scope :at_city, lambda {|city| where(:city_id => city.id) }
  scope :filter_group, lambda  {|search_hash| where(search_hash)}
  scope :of_item, lambda  {|item_id| where(:item_id => item_id)}
  scope :pass_audit, lambda { where("status = ? ", Group::PASSED ) }  
  scope :to_be_audit, lambda { where("status = ? ", Group::BEING_REVIEWED) }  
  scope :audit_failed, lambda { where("status = ? ", Group::DENIED) } 
  scope :canceled, lambda { where("status = ? ", Group::CANCELED_BY_EVENT_ADMIN) } 
  scope :all, lambda { select("*") }

  


  def image_url(size = :thumb_large)
    result = if size == :thumb_medium && self[:image_url_medium]
               self[:image_url_medium]
             elsif size == :thumb_small && self[:image_url_small]
               self[:image_url_small]
             else
               self[:image_url_large]
             end
    (result != nil && result.length > 0) ? result : default_url(size)
  end

  def self.update_avatar_urls(params,url_params)
      group = find(params[:photo][:model_id])
      group.update_attributes(url_params)
  end

  def self.interested_groups(city,person)
    groups  = []
    person.interests.each do |item|
      groups += Group.where(:item_id => item.id, :city_id => city.id).order('members_count desc').limit(6)
    end
    groups
  end

  def self.hot_group_by_item(city, item)
    Group.of_item(item).at_city(city).order('members_count desc').limit(5)
  end

  def need_invitation_from_admin
    join_mode == JOIN_BY_INVITATION_FROM_ADMIM 
  end


  def need_invitation
    join_mode == JOIN_BY_INVITATION_FROM_ADMIM
  end

  def need_authenticate
    join_mode == JOIN_AFTER_AUTHENTICATAION
  end

  def joinable?(person)
    m = Membership.where(:person_id => person.id, :group_id => self.id)
    if (join_mode == JOIN_FREE || join_mode == JOIN_AFTER_AUTHENTICATAION)
      if (m.size == 0)
        return true
      else
        return m[0].pending == true && m[0].pending_type== JOIN_BY_INVITATION_FROM_ADMIM 
      end
    else
      return m.size > 0 && m[0].pending == true 
    end 
  end

  def has_admin?(person) 
    Membership.where(:group_id => id, :person_id => person.id, :is_admin => true, :pending => false).count > 0 
  end

  def has_member?(person)
    Membership.where(:group_id => id, :person_id => person.id, :pending => false).count > 0 
  end

  def has_pending_member?(person)
    Membership.where(:person_id => person.id, :group_id => id,
                     :pending => true).size > 0
  end
  
  def applied_pending_member?(person)
    Membership.where(:person_id => person.id, :group_id => id,
                     :pending => true, :pending_type=> Group::JOIN_AFTER_AUTHENTICATAION).size > 0
  end

  def has_member_include_pending?(person)
    Membership.where(:person_id => person.id, :group_id => id).size > 0
  end

  def add_member(person)
    mship =  Membership.where(:person_id => person.id, 
                               :group_id => self.id,
                               :pending => true, :pending_type => JOIN_BY_INVITATION_FROM_ADMIM) 
    if  mship.size > 0
      mship.first.update_attributes(:pending => false)
    elsif need_authenticate 
      m = memberships.where(:person_id => person.id)
      if m.size > 0
        m.first.update_attributes(:pending => false) 
      else
        Membership.create(:person_id => person.id, :group_id => self.id,
                          :pending => true, :pending_type=>JOIN_AFTER_AUTHENTICATAION ) 
      end
    else
      Membership.create(:person_id => person.id, 
                        :group_id => self.id)
    end
  end


  def delete_member(person)
    memberships.destroy_all(:person_id => person.id)
  end

  def is_admin(person)
    memberships.where(:person_id => person.id, 
                     :is_admin => true).count > 0
  end

  def dispatch_group(action,user=self.person.user)
    Dispatch.new(user, self,action).notify_user
  end

  def subscribers(user,action=false)
    action = action.to_sym
    if action == :invite
      self.invited_people
    end
  end

  def notification_type( action=false )
    action = action.to_sym
    if action == :invite
      Notifications::InviteGroup
    end
  end

  def location  
    city.name + district.name    
  end

  def need_notice?
    status == Group::BEING_REVIEWED || status == Group::DENIED
  end
  
  def in_audit_process?
    status == Group::BEING_REVIEWED || status == Group::DENIED
  end

  def is_owner(user)
    if user
      return user.person.id == person_id
    else
      false
    end
  end


  private
  def default_url(size)
     case size
        when :thumb_medium then "/images/group/group_medium.jpg"
        when :thumb_large   then "/images/group/group_large.jpg"
        when :thumb_small   then "/images/group/group_small.jpg"
     end
  end

  def update_owner_counter
    if self.item_id_was && self.item_id_was != self.item_id
      begin
        i = Item.find(self.item_id_was)
        i.groups_count = i.groups.count
        i.save
      rescue Exception
      end
    end 
    self.item.groups_count = self.item.groups.count
    self.item.save
  end

end

