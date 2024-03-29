class AddNameAndGettingStartedToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :name, :string

    add_column :users, :getting_started,:boolean,:default => true
  end

  def self.down
    remove_column :users, :getting_started
    remove_column :users, :name
  end
end
