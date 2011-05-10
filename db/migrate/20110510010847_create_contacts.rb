class CreateContacts < ActiveRecord::Migration
  def self.up
    create_table :contacts do |t|
      t.integer :user_id
      t.integer :person_id
      t.boolean :pending, :default => true

      t.timestamps
    end
    add_index :contacts, [:user_id,:pending]
    add_index :contacts, [ :person_id,:pending ]
  end

  def self.down
    drop_table :contacts
  end
end
