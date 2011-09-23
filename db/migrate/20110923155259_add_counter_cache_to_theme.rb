class AddCounterCacheToTheme < ActiveRecord::Migration
  def self.up
    add_column :themes, :followers_count, :integer, :default => 0
    add_column :themes, :itemtopics_count, :integer, :default => 0

    Theme.reset_column_information
    Theme.find(:all).each do |theme|
      Theme.update_counters theme.id, :followers_count => theme.followers.count
      Theme.update_counters theme.id, :itemtopics_count => theme.itemtopics.count
    end
  end

  def self.down
    remove_column :themes, :followers_count
    remove_column :themes, :itemtopics_count
  end
end
