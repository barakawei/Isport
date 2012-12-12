class CreatePostVisibilities < ActiveRecord::Migration
  def self.up
    create_table :post_visibilities do |t|
      t.integer :contact_id
      t.integer :post_id
      t.timestamps
    end
  end

  def self.down
    drop_table :post_visibilities
  end
end
