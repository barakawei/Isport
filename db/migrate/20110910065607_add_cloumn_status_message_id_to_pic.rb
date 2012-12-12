class AddCloumnStatusMessageIdToPic < ActiveRecord::Migration
  def self.up
    add_column :pics, :status_message_id, :integer
  end

  def self.down
    remove_column :pics, :status_message_id
  end
end
