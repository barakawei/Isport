class AddParticipantsLimitToEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :participants_limit, :integer, :default => 100 
  end

  def self.down
    remove_column :events, :participants_limit
  end
end
