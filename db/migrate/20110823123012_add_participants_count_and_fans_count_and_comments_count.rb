class AddParticipantsCountAndFansCountAndCommentsCount < ActiveRecord::Migration
  def self.up
    add_column :events, :participants_count, :integer, :default => 0
    add_column :events, :comments_count, :integer, :default => 0
    add_column :events, :fans_count, :integer, :default => 0

    Event.all.each {|e| e.update_attributes(:participants_count => e.participants.count,
                                             :comments_count => e.comments.count,
                                             :fans_count => e.recommendations.count)}
  end

  def self.down
    remove_column :events, :participants_count
    remove_column :events, :comments_count
    remove_column :events, :fans_count
  end
end
