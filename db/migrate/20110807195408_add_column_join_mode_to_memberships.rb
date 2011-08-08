class AddColumnJoinModeToMemberships < ActiveRecord::Migration
  def self.up
    add_column :memberships, :join_mode, :integer, :default => 1 
  end

  def self.down
    remove_column :memberships, :join_mode
  end
end
