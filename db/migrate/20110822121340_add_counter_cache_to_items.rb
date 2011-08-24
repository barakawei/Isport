class AddCounterCacheToItems < ActiveRecord::Migration
  def self.up
    add_column :items, :fans_count, :integer, :default => 0
    add_column :items, :events_count, :integer, :default => 0
    add_column :items, :groups_count, :integer, :default => 0

    Item.reset_column_information
    Item.find(:all).each do |item|
      Item.update_counters item.id, :fans_count => item.fans.count
      Item.update_counters item.id, :events_count => item.events.count
      Item.update_counters item.id, :groups_count => item.groups.count
    end
  end

  def self.down
    remove_column :items, :fans_count
    remove_column :items, :events_count
    remove_column :items, :groups_count
  end

end
