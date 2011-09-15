class AddCommentsCountToPics < ActiveRecord::Migration
  def self.up
    add_column :pics, :comments_count, :integer, :default => 0

    Pic.reset_column_information
    Pic.find(:all).each do |pic|
      Pic.update_counters pic.id, :comments_count => pic.comments.count
    end
  end

  def self.down
    remove_column :pics, :comments_count
  end
end
