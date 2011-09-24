class AddCounterCacheToItemtopic < ActiveRecord::Migration
  def self.up
    add_column :item_topics, :followers_count, :integer, :default => 0
    add_column :item_topics, :comments_count, :integer, :default => 0

    ItemTopic.reset_column_information
    ItemTopic.find(:all).each do |itemtopic|
      ItemTopic.update_counters itemtopic.id, :followers_count => itemtopic.followers.count
      ItemTopic.update_counters itemtopic.id, :comments_count => itemtopic.comments.count
    end
  end

  def self.down
    remove_column :item_topics, :followers_count
    remove_column :item_topics, :comments_count
  end
end
