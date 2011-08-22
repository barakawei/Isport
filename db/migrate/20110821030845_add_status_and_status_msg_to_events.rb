class AddStatusAndStatusMsgToEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :status, :integer, :default => 0
    add_column :events, :status_msg, :string
  end

  def self.down
    remove_column :events, :status
    remove_column :events, :status_msg
  end
end
