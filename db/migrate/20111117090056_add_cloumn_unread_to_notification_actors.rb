class AddCloumnUnreadToNotificationActors < ActiveRecord::Migration
  def self.up
    add_column :notification_actors, :unread, :integer,:default => 1
  end

  def self.down
    remove_column :notification_actors, :unread
  end
end
