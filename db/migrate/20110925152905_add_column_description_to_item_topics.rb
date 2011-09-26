class AddColumnDescriptionToItemTopics < ActiveRecord::Migration
  def self.up
    add_column :item_topics, :description, :text
  end

  def self.down
    remove_column :item_topics, :description
  end
end
