class CreateTopics < ActiveRecord::Migration
  def self.up
    create_table :topics do |t|
      t.string :title
      t.text :content
      t.integer :person_id
      t.integer :forum_id

      t.timestamps
    end
  end

  def self.down
    drop_table :topics
  end
end
