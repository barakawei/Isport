class ChangeColumnJoinModeInMemberships < ActiveRecord::Migration
  def self.up
    rename_column :memberships, :join_mode, :pending_type 
  end

  def self.down
    rename_column :memberships, :pending_type, :join_mode 
  end
end
