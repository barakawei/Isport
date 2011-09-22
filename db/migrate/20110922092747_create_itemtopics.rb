class CreateItemtopics < ActiveRecord::Migration
  def self.up
    create_table :itemtopics do |t|
      t.string :name
      t.integer :theme_id
      t.integer :city_id, :default => 0

      t.timestamps
    end
  end

  def self.down
    drop_table :itemtopics
  end
end
