class Group < ActiveRecord::Base
  belongs_to :item
  belongs_to :city
  belongs_to :person

  has_many :memberships, :dependent => :destroy
  has_many :members, :through => :memberships,  :source => :person

  
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

  private
  def default_url(size)
     case size
        when :thumb_medium then "/images/group/group_medium.jpg"
        when :thumb_large   then "/images/group/group_large.jpg"
        when :thumb_small   then "/images/group/group_small.jpg"
     end
  end
end
