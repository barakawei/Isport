class CreateGroups < ActiveRecord::Migration
  def self.up
    create_table :groups do |t|
      t.string :name, :unique => true
      t.string :description
      t.integer :item_id
      t.integer :city_id
      t.boolean :is_private
      t.string :join_mode

      t.timestamps
    end
  end

  def self.down
    drop_table :groups
  end
end
