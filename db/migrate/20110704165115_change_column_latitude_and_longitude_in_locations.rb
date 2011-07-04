class ChangeColumnLatitudeAndLongitudeInLocations < ActiveRecord::Migration
  def self.up
    rename_column :locations, :longitude, :lng
    rename_column :locations, :latitude, :lat
  end

  def self.down
    rename_column :locations, :lng, :longitude
    rename_column :locations, :lat, :latitude 
  end
end
