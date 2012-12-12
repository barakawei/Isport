class AddCloumnAvatarProcessedImageToPics < ActiveRecord::Migration
  def self.up
    add_column :pics, :avatar_processed_image, :string
  end

  def self.down
    remove_column :pics, :avatar_processed_image
  end
end
