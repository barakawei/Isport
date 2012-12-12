class AddIndexToInvolvements < ActiveRecord::Migration
  def self.up
    add_index :involvements, :person_id
    add_index :involvements, :event_id
    add_index :involvements, [:person_id, :event_id], :unique => true 
  end

  def self.down
    remove_index :involvements, :person_id
    remove_index :involvements, :event_id
    remove_index :involvements, [:person_id, :event_id]
  end
end
