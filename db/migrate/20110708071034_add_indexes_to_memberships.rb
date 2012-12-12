class AddIndexesToMemberships < ActiveRecord::Migration
  def self.up
    add_index :memberships, :person_id
    add_index :memberships, :group_id
    add_index :memberships, [:person_id, :group_id], :unique => true 
  end

  def self.down
    remove_index :memberships, :person_id
    remove_index :memberships, :group_id
    remove_index :memberships, [:person_id, :group_id]
  end
end
