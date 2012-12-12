class AddIsPendingToInvolvements < ActiveRecord::Migration
  def self.up
    add_column :involvements, :is_pending, :boolean, :default => false
  end

  def self.down
    remove_column :involvements, :is_pending
  end
end
