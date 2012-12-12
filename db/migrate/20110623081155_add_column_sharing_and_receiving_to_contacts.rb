class AddColumnSharingAndReceivingToContacts < ActiveRecord::Migration
  def self.up
    add_column :contacts, :sharing,   :boolean,:default => false
    add_column :contacts, :receiving, :boolean,:default => false
  end

  def self.down
    remove_column :contacts,:sharing, :boolean
    remove_column :contacts,:receiving, :boolean
  end
end
