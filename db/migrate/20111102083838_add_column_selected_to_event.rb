class AddColumnSelectedToEvent < ActiveRecord::Migration
  def self.up
    add_column :events, :selected, :boolean, :default => false  
  end

  def self.down
    remove_column :events, :selected
  end
end
