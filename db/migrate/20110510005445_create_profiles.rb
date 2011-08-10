class CreateProfiles < ActiveRecord::Migration
  def self.up
    create_table :profiles do |t|
      t.string :name, :limit => 127,:default => ""
      t.string :image_url
      t.string :image_url_small
      t.date :birthday
      t.string :gender
      t.text :bio
      t.integer :person_id
      t.timestamps
    end
    add_index :profiles, :name
    add_index :profiles, :person_id
  end

  def self.down
    drop_table :profiles
  end
end
