class AddCloumnPicSizeToPic < ActiveRecord::Migration
  def self.up
    add_column :pics, :image_width, :integer
    add_column :pics, :image_height, :integer
  end

  def self.down
    remove_column :pics, :image_width, :integer
    remove_column :pics, :image_height, :integer
  end
end
