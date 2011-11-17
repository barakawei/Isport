class AddCloumnTargetIdAndTargetTypeToNotificationActors < ActiveRecord::Migration
  def self.up
    add_column :notification_actors, :target_id, :integer
    add_column :notification_actors, :target_type, :string
  end

  def self.down
    remove_column :notification_actors, :target_type
    remove_column :notification_actors, :target_id
  end
end
