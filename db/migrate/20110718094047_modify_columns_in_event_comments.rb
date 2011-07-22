class ModifyColumnsInEventComments < ActiveRecord::Migration
  def self.up
    rename_column :event_comments, :event_id, :commentable_id
    add_column :event_comments, :commentable_type, :string
  end

  def self.down
    rename_column :event_comments, :commentable_id, :event_id
    remove_column :event_comments, :commentable_type
  end
end
