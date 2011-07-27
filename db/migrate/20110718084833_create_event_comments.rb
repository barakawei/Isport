class CreateEventComments < ActiveRecord::Migration
  def self.up
    create_table :event_comments do |t|
      t.integer :person_id
      t.text :content
      t.integer :commentable_id
      t.string :commentable_type

      t.timestamps
    end
  end

  def self.down
    drop_table :event_comments
  end
end
