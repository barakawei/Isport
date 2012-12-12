class AddCloumnHobbyToProfile < ActiveRecord::Migration
  def self.up
    add_column :profiles, :hobby, :text
  end

  def self.down
    remove_column :profiles, :hobby
  end
end
