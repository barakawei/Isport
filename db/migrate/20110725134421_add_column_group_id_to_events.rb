class AddColumnGroupIdToEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :group_id, :integer, :default => 0
  end

  def self.down
    remove_column :events, :group_id
  end
end
