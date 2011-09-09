class ChangeColumnEventIdInPics < ActiveRecord::Migration
  def self.up
    rename_column :pics, :event_id, :album_id
  end

  def self.down
    rename_column :pics, :album_id, :event_id
  end
end
