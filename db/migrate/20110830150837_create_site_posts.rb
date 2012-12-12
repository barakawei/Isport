class CreateSitePosts < ActiveRecord::Migration
  def self.up
    create_table :site_posts do |t|
      t.integer :person_id
      t.string :title
      t.text :content

      t.timestamps
    end
  end

  def self.down
    drop_table :site_posts
  end
end
