class CreateNotifications < ActiveRecord::Migration
  def self.up
    create_table :notifications do |t|
      t.string :target_type
      t.integer :target_id
      t.integer :recipient_id
      t.string :type
      t.boolean :unread, :default => true
      t.timestamps
    end
  end

  def self.down
    drop_table :notifications
  end
end
