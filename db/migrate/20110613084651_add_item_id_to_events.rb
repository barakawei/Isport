class AddItemIdToEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :item_id, :integer
  end

  def self.down
    remove_column :events, :item_id
  end
end
