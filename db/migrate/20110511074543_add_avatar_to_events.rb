class AddAvatarToEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :avatar, :string
  end

  def self.down
    remove_column :events, :avatar
  end
end
