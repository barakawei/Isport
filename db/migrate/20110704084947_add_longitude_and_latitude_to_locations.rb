class AddLongitudeAndLatitudeToLocations < ActiveRecord::Migration
  def self.up
    add_column :locations, :longitude, :decimal, :precision => 11, :scale => 8  
    add_column :locations, :latitude, :decimal, :precision => 11, :scale => 8
  end

  def self.down
    remove_column :locations, :longitude
    remove_column :locations, :latitude
  end
end
