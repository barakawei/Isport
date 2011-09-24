class CreateItemtopics < ActiveRecord::Migration
  def self.up
    create_table :item_topics do |t|
      t.string :name
      t.integer :item_id
      t.integer :key_topic
      t.integer :city_id, :default => 0
      t.string :image_url_large
      t.string :image_url_medium
      t.string :image_url_small

      t.timestamps
    end
  end

  def self.down
    drop_table :item_topics
  end
end
