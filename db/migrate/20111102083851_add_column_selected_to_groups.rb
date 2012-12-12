class AddColumnSelectedToGroups < ActiveRecord::Migration
  def self.up
    add_column :groups, :selected, :boolean, :default => false  
  end

  def self.down
    remove_column :groups, :selected
  end
end
