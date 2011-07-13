class ChangeColumnPendingInMemberships < ActiveRecord::Migration
  def self.up
    change_column :memberships, :pending, :boolean, :default => false 
  end

  def self.down
    change_column :memberships, :pending, :boolean
  end
end
