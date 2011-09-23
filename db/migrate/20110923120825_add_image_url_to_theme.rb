class AddImageUrlToTheme < ActiveRecord::Migration
  def self.up
    add_column :themes, :image_url_small, :string
    add_column :themes, :image_url_medium, :string
    add_column :themes, :image_url_large, :string

  end

  def self.down
    remove_column :themes, :image_url_small
    remove_column :themes, :image_url_medium
    remove_column :themes, :image_url_large
  end
end
