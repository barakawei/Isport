class CreatePicComments < ActiveRecord::Migration
  def self.up
    create_table :pic_comments do |t|
      t.integer :pic_id
      t.integer :person_id
      t.text :content
      t.timestamps
    end
  end

  def self.down
    drop_table :pic_comments
  end
end
