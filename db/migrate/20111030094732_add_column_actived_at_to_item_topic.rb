class AddColumnActivedAtToItemTopic < ActiveRecord::Migration
  def self.up
    add_column :item_topics, :activated_at, :timestamp
    
    ItemTopic.all.each do |i|
      last_post = i.posts.order("created_at desc").first 
      if last_post
        i.update_attributes(:activated_at => last_post.created_at)
      elsif
        i.update_attributes(:activated_at => i.created_at)
      end
    end  
  end

  def self.down
    remove_column :item_topics, :activated_at, :timestamp
  end
end
