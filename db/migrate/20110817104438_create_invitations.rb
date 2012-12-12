class CreateInvitations < ActiveRecord::Migration
  def self.up
    create_table :invitations do |t|
      t.integer :sender_id
      t.integer :recipient_id
      t.text :message
      
      t.timestamps
    end
  end

  def self.down
    drop_table :invitations
  end
end
