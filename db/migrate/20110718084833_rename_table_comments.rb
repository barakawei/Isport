class RenameTableComments < ActiveRecord::Migration
  def self.up
    rename_table :comments, :event_comments
  end

  def self.down
    rename_table :event_comments, :comments
  end
end
