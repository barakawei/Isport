class AddImageUrlMediumAndImageUrlSmallToItems < ActiveRecord::Migration
  def self.up
    add_column :items, :image_url_medium, :string
    add_column :items, :image_url_small, :string
    rename_column :items, :image_url, :image_url_large
  end

  def self.down
    remove_column :items, :image_url_small
    remove_column :items, :image_url_medium
    rename_column :items, :image_url_large, :image_url
  end
end
