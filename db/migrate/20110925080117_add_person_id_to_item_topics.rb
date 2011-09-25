class AddPersonIdToItemTopics < ActiveRecord::Migration
  def self.up
    add_column :item_topics, :person_id, :integer
  end

  def self.down
    remove_column :item_topics, :person_id
  end
end
