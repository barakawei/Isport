class SitePost < ActiveRecord::Base
  belongs_to :person
  scope :next_post, lambda {|post| where('created_at > ?', post.created_at).order('created_at asc').limit(1)} 
  scope :previous_post, lambda {|post| where('created_at < ?', post.created_at).order('created_at desc').limit(1)} 
end
