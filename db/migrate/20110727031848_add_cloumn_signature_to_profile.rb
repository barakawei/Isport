class AddCloumnSignatureToProfile < ActiveRecord::Migration
  def self.up
    add_column :profiles, :signature, :text
  end

  def self.down
    remove_column :profiles, :signature
  end
end
