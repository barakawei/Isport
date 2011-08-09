class AddCategoryIdToItems < ActiveRecord::Migration
  def self.up
    add_column :items, :category_id, :integer, :default => 1
  end

  def self.down
    remove_column :items, :category_id
  end
end
