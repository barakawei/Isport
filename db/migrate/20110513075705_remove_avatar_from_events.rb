class RemoveAvatarFromEvents < ActiveRecord::Migration
  def self.up
    remove_column :events, :avatar
  end

  def self.down
    add_column :events, :avatar, :string
  end
end
