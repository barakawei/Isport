class ModifyColumnsOfEventComments < ActiveRecord::Migration
  def self.up
    remove_column :event_comments,  :type 
    rename_column :event_comments, :item_id, :event_id
  end

  def self.down
    add_column :event_comments, :type, :string
    rename_column :event_comments, :event_id, :item_id
  end
end
