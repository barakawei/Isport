class AddColumnBindStatusToAuthorizations < ActiveRecord::Migration
  def self.up
    add_column :authorizations, :bind_status, :integer, :default => 0
  end

  def self.down
    remove_column :authorizations, :bind_status
  end
end
