class AddRandomStringToPosts < ActiveRecord::Migration
  def self.up
    add_column :posts, :random_string, :string
  end

  def self.down
    remove_column :posts, :random_string
  end
end
