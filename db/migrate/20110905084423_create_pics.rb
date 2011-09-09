class CreatePics < ActiveRecord::Migration
  def self.up
    create_table :pics do |t|
      t.integer :author_id
      t.integer :event_id
      t.text :description
      t.text :remote_photo_path
      t.string :remote_photo_name
      t.string :processed_image
      t.string :unprocessed_image
      t.string :random_string

      t.timestamps
    end
  end

  def self.down
    drop_table :pics
  end
end
