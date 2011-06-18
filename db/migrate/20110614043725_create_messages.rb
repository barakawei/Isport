class CreateMessages < ActiveRecord::Migration
  def self.up
    create_table :messages do |t|
      t.integer :conversation_id
      t.integer :person_id
      t.text  :text
      t.timestamps
    end
  end

  def self.down
    drop_table :messages
  end
end
