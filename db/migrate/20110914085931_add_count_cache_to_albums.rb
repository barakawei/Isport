class AddCountCacheToAlbums < ActiveRecord::Migration
  def self.up
    add_column :albums, :pics_count, :integer, :default => 0

    Album.reset_column_information
    Album.find(:all).each do |album|
      Album.update_counters album.id, :pics_count => album.pics.count 
    end
  end

  def self.down
    remove_column :albums, :pics_count
  end
end
