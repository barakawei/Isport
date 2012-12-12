class AddItemtopicIdToPost < ActiveRecord::Migration
  def self.up
    add_column :posts, :item_topic_id, :integer
  end

  def self.down
    remove_column :posts, :item_topic_id
  end
end
