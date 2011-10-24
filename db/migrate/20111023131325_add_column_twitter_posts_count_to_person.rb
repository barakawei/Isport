class AddColumnTwitterPostsCountToPerson < ActiveRecord::Migration
  def self.up
    add_column :people, :twitter_posts_count, :integer

    Person.reset_column_information
    Person.find(:all).each do |person|
      Person.update_counters person.id, :twitter_posts_count => person.twitter_posts.count
    end
  end

  def self.down
    remove_column :people, :twitter_posts_count
  end
end
