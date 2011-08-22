class Topic < ActiveRecord::Base
  attr_accessor :url

  after_save :update_owner_counter
  after_destroy :update_owner_counter
  after_update :update_owner_counter

  belongs_to :forum
  belongs_to :person

  has_many :comments, :class_name => 'TopicComment', :as => :commentable

  def latest_comment_time
    comment =  comments.order('created_at desc').limit(1)
    comment.size > 0 ? comment[0].created_at : self.created_at
  end

  private

  def update_owner_counter
    if self.forum.discussable_type == "Group"
      group = Group.find(self.forum.discussable_id)
      group.topics_count = group.topics.count
      group.save
    end
  end
end
