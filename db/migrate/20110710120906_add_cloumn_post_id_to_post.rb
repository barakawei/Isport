class AddCloumnPostIdToPost < ActiveRecord::Migration
  def self.up
    add_column :posts, :post_id, :integer
  end

  def self.down
    remove_column :posts, :post_id
  end
end
