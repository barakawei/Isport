class ChangeColumnUnreadAtNotifications < ActiveRecord::Migration
  def self.up
    change_column :notifications,:unread,:integer,:default => 1
  end

  def self.down
  end
end
