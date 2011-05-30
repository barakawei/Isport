class CreateRecommendations < ActiveRecord::Migration
  def self.up
    create_table :recommendations do |t|
      t.integer :item_id
      t.integer :person_id
      t.string :type 
      t.timestamps
    end
  end

  def self.down
    drop_table :recommendations
  end
end
