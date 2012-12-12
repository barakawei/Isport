class AddColumnAuditPersonIdToEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :audit_person_id, :integer
  end

  def self.down
    remove_column :events, :audit_person_id
  end
end
