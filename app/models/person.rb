class Person < ActiveRecord::Base
  cattr_reader :per_page
  @@per_page = 10

  belongs_to :user
  has_many :contacts
  has_many :events
  has_many :groups
  has_many :topics
  has_many :topic_comments, :class_name => 'topic_comment'

  has_many :involvements, :dependent => :destroy
  has_many :involved_events, :through => :involvements, :source => :event

  has_many :memberships, :dependent => :destroy
  has_many :joined_groups, :through => :memberships, :source => :group

  has_many :favorites, :dependent => :destroy
  has_many :interests, :through => :favorites, :source => :item

  has_many :event_recommendations, :dependent => :destroy
  has_many :recommended_events, :through => :event_recommendations,
           :source => :event
   
  has_one :profile
  scope :searchable, joins(:profile) 
  scope :friends_of, lambda {|user| where("user_id = ?", user.id)} 

  delegate :name, :to => :profile
  delegate :email, :to => :user
  delegate :location, :to => :profile
  
  def self.search(query,user)
    return [] if query.to_s.blank? || query.to_s.length < 1

    where_clause = <<-SQL
      profiles.name LIKE ? OR
      profiles.name LIKE ?
    SQL
    sql =""
    tokens = []
    query_tokens = query.to_s.strip.split(" ")
    query_tokens.each_with_index do |raw_token,i|
      token = "#{raw_token}%"
      up_token ="#{raw_token.titleize}%"
      sql << " OR " unless i==0
      sql << where_clause
      tokens.concat([token,up_token])
    end
    Person.searchable.where(sql,*tokens)
  end

  def as_json(opts={})
    {
    :person => {
        :id => self.id,
        :name => self.name,
        :image_url =>self.profile.image_url(:thumb_small)
      }
    }
  end 

  def add_interests(item_ids)
    item_ids.each do |item_id|
      Favorite.create(:item_id => item_id, :person_id => self.id)
    end
  end
end
