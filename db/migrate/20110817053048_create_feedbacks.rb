class CreateFeedbacks < ActiveRecord::Migration
  def self.up
    create_table :feedbacks do |t|
      t.integer :person_id
      t.text :content

      t.timestamps
    end
  end

  def self.down
    drop_table :feedbacks
  end
end
