class AddColumnDistrictIdToGroups < ActiveRecord::Migration
  def self.up
    add_column :groups, :district_id, :integer
  end

  def self.down
    remove_column :groups, :district_id
  end
end
