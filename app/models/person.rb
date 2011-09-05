class Person < ActiveRecord::Base
  cattr_reader :per_page
  @@per_page = 10

  belongs_to :user
  has_many :contacts
  has_many :events
  has_many :feedbacks
  has_many :groups
  has_many :topics
  has_many :topic_comments, :class_name => 'TopicComment'
  has_many :event_comments, :class_name => 'EventComment'
  has_many :site_posts

  has_many :involvements, :dependent => :destroy
  has_many :involved_events, :through => :involvements, :source => :event,
                          :conditions => ['involvements.is_pending = ?', false]

  has_many :audit_events, :foreign_key  => "audit_person_id", :class_name => 'Event' 
  has_many :audit_groups, :foreign_key => "audit_person_id", :class_name => 'Group' 
  has_many :memberships, :dependent => :destroy
  has_many :joined_groups, :through => :memberships, :source => :group,
                        :conditions => ['memberships.pending = ? ', false]

  has_many :favorites, :dependent => :destroy
  has_many :interests, :through => :favorites, :source => :item

  has_many :event_recommendations, :dependent => :destroy
  has_many :recommended_events, :through => :event_recommendations,
           :source => :event
   
  has_one :profile
  scope :friends_of, lambda {|user| where("user_id = ?", user.id)} 
  scope :at_city, lambda {|city_id| joins(:profile => :location).where(:locations => {:city_id => city_id})}

  delegate :name, :to => :profile
  delegate :email, :to => :user
  delegate :location, :to => :profile
  
  def self.search(query,user)
    return [] if query.to_s.blank? || query.to_s.length < 1

    where_clause = <<-SQL
      people.id != #{user.person.id} and profiles.name LIKE ?
    SQL
    sql =""
    tokens = []
    query_tokens = query.to_s.strip.split(" ")
    query_tokens.each_with_index do |raw_token,i|
      token = "%#{raw_token}%"
      sql << " OR " unless i==0
      sql << where_clause
      tokens.concat([token])
    end
    Person.joins( :profile ).where(sql,*tokens)
  end

  def as_json(opts={})
    {
    :person => {
        :id => self.id,
        :name => self.name,
        :image_url =>self.profile.image_url(:thumb_small),
        :url => "/people/#{self.id}"
      }
    }
  end 

  def add_interests(item_ids)
    item_ids.each do |item_id|
      Favorite.create(:item_id => item_id, :person_id => self.id)
    end
  end

end

