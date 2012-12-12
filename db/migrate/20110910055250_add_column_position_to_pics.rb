class AddColumnPositionToPics < ActiveRecord::Migration
  def self.up
    add_column :pics, :position, :integer
  end

  def self.down
    remove_column :pics, :position
  end
end
