class Group < ActiveRecord::Base
  JOIN_FREE = 1 
  JOIN_AFTER_AUTHENTICATAION = 2 
  JOIN_BY_INVITATION_FROM_ADMIM = 3 

  belongs_to :item
  belongs_to :city
  belongs_to :district
  belongs_to :person
  attr_accessor :invited_people

  validates_presence_of :name, :description, :item_id, :city_id, :district_id,
                        :join_mode,
                        :message => I18n.t('activerecord.errors.messages.blank')

  validates_length_of :name, :maximum => 30
  validates_length_of :description, :maximum => 1500 


  has_many :memberships, :dependent => :destroy
  has_many :events
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

  has_one :forum,  :as => :discussable
  has_many :topics, :through => :forum, :source => :topics

  scope :at_city, lambda {|city| where(:city_id => city.id) }
  scope :filter_group, lambda  {|search_hash| where(search_hash)}
  


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

  def self.hot_groups(city)
     groups = Group.joins(:memberships).where(:city_id => city.id)
            .group(:group_id).order('count(group_id) desc').limit(3);
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
    membership =  Membership.where(:person_id => person.id, 
                               :group_id => self.id,
                               :pending => true, :pending_type => JOIN_BY_INVITATION_FROM_ADMIM) 
    if  membership.size > 0
      membership.first.update_attributes(:pending => false)
    elsif need_authenticate
      Membership.create(:person_id => person.id, :group_id => self.id,
                        :pending => true, :pending_type=>JOIN_AFTER_AUTHENTICATAION ) 
    else
      Membership.create(:person_id => person.id, 
                        :group_id => self.id)
    end
  end


  def delete_member(person)
    Membership.delete_all(:group_id => id, :person_id => person.id)
  end

  def is_admin(person)
    Membership.where(:person_id => person.id, 
                     :group_id => self.id, :is_admin => true).count > 0
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

  private
  def default_url(size)
     case size
        when :thumb_medium then "/images/group/group_medium.jpg"
        when :thumb_large   then "/images/group/group_large.jpg"
        when :thumb_small   then "/images/group/group_small.jpg"
     end
  end
end
