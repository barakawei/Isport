class AddCountCacheToGroups < ActiveRecord::Migration
  def self.up
    add_column :groups, :members_count, :integer, :default => 0
    add_column :groups, :events_count, :integer, :default => 0
    add_column :groups, :topics_count, :integer, :default => 0

    Group.reset_column_information
    Group.find(:all).each do |g|
      g.update_attribute :members_count, g.members.length
      g.update_attribute :events_count, g.events.length
      g.update_attribute :topics_count, g.topics.length
    end
  end

  def self.down
    remove_column :groups, :members_count
    remove_column :groups, :events_count
    remove_column :groups, :topics_count
  end
end
