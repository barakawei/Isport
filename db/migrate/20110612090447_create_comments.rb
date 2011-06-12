class CreateComments < ActiveRecord::Migration
  def self.up
    create_table :comments do |t|
      t.integer :person_id
      t.text :content
      t.integer :item_id

      t.timestamps
    end
  end

  def self.down
    drop_table :comments
  end
end
