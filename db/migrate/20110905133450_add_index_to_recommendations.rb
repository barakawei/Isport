class AddIndexToRecommendations < ActiveRecord::Migration
  def self.up
    add_index :recommendations, :person_id
    add_index :recommendations, :item_id
    add_index :recommendations, [:person_id, :item_id], :unique => true
  end

  def self.down
    remove_index :recommendations, :person_id
    remove_index :recommendations, :item_id
    remove_index :recommendations, [:person_id, :item_id]
  end
end
