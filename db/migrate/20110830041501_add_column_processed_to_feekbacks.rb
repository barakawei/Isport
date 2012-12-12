class AddColumnProcessedToFeekbacks < ActiveRecord::Migration
  def self.up
    add_column :feedbacks, :processed, :boolean, :default => false
  end

  def self.down
    remove_column :feedbacks, :processed
  end
end
