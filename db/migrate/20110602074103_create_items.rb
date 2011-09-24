class CreateItems < ActiveRecord::Migration
  def self.up
    create_table :items do |t|
      t.string :name
      t.text :description
      t.string :image_url_large
      t.string :image_url_medium
      t.string :image_url_small

      t.timestamps
    end
  end

  def self.down
    drop_table :items
  end
end
