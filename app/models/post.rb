class Post < ActiveRecord::Base
  belongs_to :author, :class_name => 'Person', :counter_cache => "twitter_posts_count" 
  has_many :post_visibilities
  has_many :people, :through => :post_visibilities
  has_many :comments, :dependent => :destroy
  has_many :mentions, :dependent => :destroy
  belongs_to :item_topic, :counter_cache => true
  scope :by_view, lambda { |person_id| select("distinct(posts.id),posts.*").joins( "left join post_visibilities pv on(posts.id = pv.post_id) ").where( "posts.type='StatusMessage' and (author_id = ? or pv.person_id = ?)",person_id,person_id)}
  scope :by_owner, lambda { |person_id| where(:author_id => person_id,:type =>"StatusMessage")}
  scope :refresh,  lambda { |current_user| where("posts.created_at > ? and author_id != ?",current_user.last_request_at,current_user.person.id) }

  def subscribers(user,action)
    user.befollowed_people
  end
  
  def dispatch_post( action=false )
    Dispatch.new(self.author.user, self,action).dispatch_status_message
  end

  def last_three_comments
    self.comments.order('created_at DESC').limit(3).includes(:author => :profile).reverse
  end 
  
  
  def as_json(opts={})
    {
        :post => {
          :id => self.id
        }
    }
  end  
  
end

