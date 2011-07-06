class CreateNotificationActors < ActiveRecord::Migration
  def self.up
    create_table :notification_actors do |t|
      t.integer :notification_id
      t.integer :person_id  
      t.timestamps
    end
  end

  def self.down
    drop_table :notification_actors
  end
end
