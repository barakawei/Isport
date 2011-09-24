class CreateItemtopicfollowships < ActiveRecord::Migration
  def self.up
    create_table :item_topic_followships do |t|
      t.integer :item_topic_id
      t.integer :person_id

      t.timestamps
    end
  end

  def self.down
    drop_table :item_topic_followships
  end
end
