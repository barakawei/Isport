class AddCloumnCommnetIdToMentions < ActiveRecord::Migration
  def self.up
    add_column :mentions, :comment_id, :integer
  end

  def self.down
    remove_column :mentions, :comment_id
  end
end
