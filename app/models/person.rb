class Person < ActiveRecord::Base
  cattr_reader :per_page
  @@per_page = 10

  belongs_to :user
  has_many :contacts
  has_many :events
  has_many :feedbacks
  has_many :groups
  has_many :topics
  has_many :item_topics
  has_many :pics,  :foreign_key => 'author_id'
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
  has_many :albums, :as => :imageable
  has_many :post_visibilities
  has_many :posts, :through => :post_visibilities

  has_many :item_topic_followships, :dependent => :destroy
  has_many :concern_itemtopics, :through => :item_topic_followships, :source => :item_topic

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
        :id => self.id,
        :name => self.name,
        :avatar => self.profile.image_url(:thumb_small),
        :image_url =>self.profile.image_url(:thumb_small),
        :url => "/people/#{self.id}"
    }
  end 

  def notification_type( action=false )
    Notifications::StartedSharing
  end

  def add_interests(item_ids)
    item_ids.each do |item_id|
      Favorite.create(:item_id => item_id, :person_id => self.id)
    end
  end

  def my_albums
    person_albums = self.albums
    events = self.involved_events
    event_albums = Album.joins( :pics ).where( "albums.imageable_type=?","Event" ).where(:imageable_id => events).where("pics.author_id" => self).group("albums.id")
    albums = person_albums + event_albums
    albums.sort! { |a,b| a.created_at <=> b.created_at } 
  end

end

