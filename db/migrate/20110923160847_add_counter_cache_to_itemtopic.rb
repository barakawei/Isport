class AddCounterCacheToItemtopic < ActiveRecord::Migration
  def self.up
    add_column :itemtopics, :followers_count, :integer, :default => 0
    add_column :itemtopics, :comments_count, :integer, :default => 0

    Itemtopic.reset_column_information
    Itemtopic.find(:all).each do |itemtopic|
      Itemtopic.update_counters itemtopic.id, :followers_count => itemtopic.followers.count
      Itemtopic.update_counters itemtopic.id, :comments_count => itemtopic.comments.count
    end
  end

  def self.down
    remove_column :itemtopics, :followers_count
    remove_column :itemtopics, :comments_count
  end
end
