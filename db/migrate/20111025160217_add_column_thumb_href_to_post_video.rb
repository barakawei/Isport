class AddColumnThumbHrefToPostVideo < ActiveRecord::Migration
  def self.up
    add_column :post_videos, :thumb_href, :string 
  end

  def self.down
    remove_column :post_videos, :thumb_href
  end
end
