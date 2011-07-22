class CreatePosts < ActiveRecord::Migration
  def self.up
    create_table :posts do |t|
      t.integer :author_id
      t.string :type
      t.text :content
      t.text :remote_photo_path
      t.string :remote_photo_name
      t.string :processed_image
      t.string :unprocessed_image

      t.timestamps
    end
  end

  def self.down
    drop_table :posts
  end
end
