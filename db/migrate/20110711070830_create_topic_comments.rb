class CreateTopicComments < ActiveRecord::Migration
  def self.up
    create_table :topic_comments do |t|
      t.text :content
      t.integer :commentable_id
      t.string :commentable_type

      t.timestamps
    end
  end

  def self.down
    drop_table :topic_comments
  end
end
