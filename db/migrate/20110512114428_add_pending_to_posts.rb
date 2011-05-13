class AddPendingToPosts < ActiveRecord::Migration
  def self.up
    add_column :posts, :pending, :boolean, :default => false
  end

  def self.down
    remove_column :posts, :pending
  end
end
