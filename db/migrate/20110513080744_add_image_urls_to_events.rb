class AddImageUrlsToEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :image_url, :string
    add_column :events, :image_url_medium, :string
    add_column :events, :image_url_small, :string
  end

  def self.down
    remove_column :events, :image_url, :string
    remove_column :events, :image_url_medium, :string
    remove_column :events, :image_url_small, :string
  end
end
