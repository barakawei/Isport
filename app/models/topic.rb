class Topic < ActiveRecord::Base
  attr_accessor :url

  belongs_to :forum
  belongs_to :person

  has_many :comments, :class_name => 'TopicComment', :as => :commentable
 
end
