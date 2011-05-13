class AddImageUrlMediumAndLocationToProfiles < ActiveRecord::Migration
  def self.up
    add_column :profiles, :image_url_medium, :string
    add_column :profiles, :location, :string
  end

  def self.down
    remove_column :profiles, :location
    remove_column :profiles, :image_url_medium
  end
end
