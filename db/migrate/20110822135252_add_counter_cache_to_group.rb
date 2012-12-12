class AddCounterCacheToGroup < ActiveRecord::Migration
  def self.up
    add_column :groups, :members_count, :integer, :default => 0
    add_column :groups, :events_count, :integer, :default => 0
    add_column :groups, :topics_count, :integer, :default => 0

    Group.reset_column_information
    Group.find(:all).each do |group|
      Group.update_counters group.id, :members_count => group.members.count
      Group.update_counters group.id, :events_count => group.events.count
      Group.update_counters group.id, :topics_count => group.topics.count
    end
  end

  def self.down
    remove_column :groups, :members_count
    remove_column :groups, :events_count
    remove_column :groups, :topics_count
  end
end
