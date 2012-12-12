class CreatePostVideos < ActiveRecord::Migration
  def self.up
    create_table :post_videos do |t|
      t.integer :status_message_id
      t.string :href

      t.timestamps
    end
  end

  def self.down
    drop_table :post_videos
  end
end
