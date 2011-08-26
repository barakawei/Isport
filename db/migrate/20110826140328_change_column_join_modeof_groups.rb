class ChangeColumnJoinModeofGroups < ActiveRecord::Migration
  def self.up
    change_column :groups, :join_mode, :integer, :default => 1 
  end

  def self.down
    change_column :groups, :join_mode, :integer
  end
end
