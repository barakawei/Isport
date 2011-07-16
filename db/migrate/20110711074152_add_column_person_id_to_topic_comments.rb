class AddColumnPersonIdToTopicComments < ActiveRecord::Migration
  def self.up
    add_column :topic_comments, :person_id, :integer
  end

  def self.down
    remove_column :topic_comments, :person_id
  end
end
