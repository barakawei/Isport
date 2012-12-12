class AddStatusAndStatusMsgAndAuditPersonToGroups < ActiveRecord::Migration
  def self.up
    add_column :groups, :status, :integer, :default => 0
    add_column :groups, :status_msg, :string
    add_column :groups, :audit_person_id, :integer
 end

  def self.down
    remove_column :groups, :status
    remove_column :groups, :status_msg
    remove_column :groups, :audit_person_id
  end
end
