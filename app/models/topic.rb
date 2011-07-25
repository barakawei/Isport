class Topic < ActiveRecord::Base
  attr_accessor :url

  belongs_to :forum
  belongs_to :person

  has_many :comments, :class_name => 'TopicComment', :as => :commentable

  def latest_comment_time
    comment =  comments.order('created_at desc').limit(1)
    comment.size > 0 ? comment[0].created_at : self.created_at
  end
end
