class ChangeColumnIsAdminInMemberships < ActiveRecord::Migration
  def self.up
    change_column :memberships, :is_admin, :boolean, :default => false 
  end

  def self.down
    change_column :memberships, :is_admin, :boolean, :default => nil 
  end
end
