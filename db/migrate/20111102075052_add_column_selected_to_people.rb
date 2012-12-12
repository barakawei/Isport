class AddColumnSelectedToPeople < ActiveRecord::Migration
  def self.up
    add_column :people, :selected, :boolean, :default => false  
  end

  def self.down
    remove_column :people, :selected
  end
end
