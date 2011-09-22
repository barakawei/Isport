class CreateItemtopicComments < ActiveRecord::Migration
  def self.up
    create_table :itemtopic_comments do |t|
      t.string :content
      t.integer :person_id
      t.integer :itemtopic_id

      t.timestamps
    end
  end

  def self.down
    drop_table :itemtopic_comments
  end
end
