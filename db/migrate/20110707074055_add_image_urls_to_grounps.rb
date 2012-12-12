class AddImageUrlsToGrounps < ActiveRecord::Migration
  def self.up
    add_column :groups, :image_url_small, :string
    add_column :groups, :image_url_medium, :string
    add_column :groups, :image_url_large, :string
  end

  def self.down
    remove_column :groups, :image_url_small
    remove_column :groups, :image_url_medium
    remove_column :groups, :image_url_large
  end
end
