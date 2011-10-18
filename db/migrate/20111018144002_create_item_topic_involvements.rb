class CreateItemTopicInvolvements < ActiveRecord::Migration
  def self.up
    create_table :item_topic_involvements do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :item_topic_involvements
  end
end
