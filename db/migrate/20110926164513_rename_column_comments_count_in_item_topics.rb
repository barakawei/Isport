class RenameColumnCommentsCountInItemTopics < ActiveRecord::Migration
  def self.up
    rename_column :item_topics, :comments_count, :posts_count
  end

  def self.down
    rename_column :item_topics, :posts_count, :comments_count 
  end
end
