class CreateItemtopicfollowships < ActiveRecord::Migration
  def self.up
    create_table :itemtopicfollowships do |t|
      t.integer :itemtopic_id
      t.integer :person_id

      t.timestamps
    end
  end

  def self.down
    drop_table :itemtopicfollowships
  end
end
