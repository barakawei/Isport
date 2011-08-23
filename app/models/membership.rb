class Membership < ActiveRecord::Base
  after_save :update_owner_counter
  after_destroy :update_owner_counter
  after_update :update_owner_counter

  belongs_to :person
  belongs_to :group
  
  private

  def update_owner_counter
    self.group.members_count = self.group.members.count
    self.save
  end
end
