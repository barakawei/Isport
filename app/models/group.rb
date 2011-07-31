class Group < ActiveRecord::Base
  belongs_to :item
  belongs_to :city
  belongs_to :district
  belongs_to :person

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
                        :conditions => ['memberships.pending = ? ', true] 
  has_many :deletable_members, :through => :memberships, :source => :person,
           :conditions => ['memberships.is_admin = ?', false] 
  has_many :related_person, :through => :memberships, :source => :person
  has_many :admins, :through => :memberships, :source => :person, 
                        :conditions => ['memberships.is_admin = ?', true]

  has_one :forum,  :as => :discussable
  has_many :topics, :through => :forum, :source => :topics

  scope :at_city, lambda {|city| where(:city_id => city.id) }
  scope :filter_group, lambda  {|search_hash| where(search_hash)}
  
  JOIN_BY_INVITATION_FROM_ADMIM = 1 
  JOIN_BY_INVITATION_FROM_MEMBER= 2
  JOIN_AFTER_AUTHENTICATAION = 3
  JOIN_FREE = 4


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

  def need_invitation_from_member
    join_mode == JOIN_BY_INVITATION_FROM_MEMBER
  end

  def need_invitation
    join_mode == JOIN_BY_INVITATION_FROM_ADMIM ||
    join_mode == JOIN_BY_INVITATION_FROM_MEMBER
  end

  def need_authenticate
    join_mode == JOIN_AFTER_AUTHENTICATAION
  end

  def is_admin(person) 
     
  end

  def add_member(person)
    membership =  Membership.where(:person_id => person.id, 
                               :group_id => self.id,
                               :pending => true)
    if need_invitation
      membership.first.update_attributes(:pending => false) if  membership.size > 0
    elsif need_authenticate
      Membership.create(:person_id => person.id, :group_id => self.id,
                        :pending => true) 
    else
      Membership.create(:person_id => person.id, 
                        :group_id => self.id)
    end
  end

  def has_member?(person)
    Membership.where(:person_id => person.id, :group_id => id,
                     :pending => false).size > 0
  end

  def has_pending_member?(person)
    Membership.where(:person_id => person.id, :group_id => id,
                     :pending => true).size > 0 
  end

  def delete_member(person)
    Membership.delete_all(:group_id => id, :person_id => person.id)
  end

  def is_admin(person)
    Membership.where(:person_id => person.id, 
                     :group_id => self.id, :is_admin => true).count > 0
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
