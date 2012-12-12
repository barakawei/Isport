class AddColumnPersonIdToGroups < ActiveRecord::Migration
  def self.up
    add_column :groups, :person_id, :integer
  end

  def self.down
    remove_column :groups, :person_id
  end
end
