class CreateConversationVisibilities < ActiveRecord::Migration
  def self.up
    create_table :conversation_visibilities do |t|
      t.integer :conversation_id
      t.integer :person_id
      t.integer :unread,:default => 0

      t.timestamps
    end
  end

  def self.down
    drop_table :conversation_visibilities
  end
end
