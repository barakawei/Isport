class Event < ActiveRecord::Base
  COMMENT_PER_PAGE = 5 
  SORT_BY_STARTTIME = "by_starttime"
  SORT_BY_POPULARITY= "by_popularity"
  PARTICIPANTS_LIMIT_MIN = 0
  PARTICIPANTS_LIMIT_MAX = 100 

  attr_accessor :same_day, :current_year,:invited_people
  validates_presence_of :title, :start_at, :description, :subject_id,
                        :participants_limit, 
                        :message => I18n.t('activerecord.errors.messages.blank')
  
  validates_length_of :title, :maximum => 30
  validates_length_of :description, :maximum => 800
  validates_numericality_of :participants_limit, :only_integer => true,
                            :greater_than => PARTICIPANTS_LIMIT_MIN,
                            :less_than_or_equal_to => PARTICIPANTS_LIMIT_MAX

  validates :end_at, :date => { :after => :start_at,
                                :message => I18n.t('activerecord.errors.event.end_at.after')}

  validate :participants_limit_cannot_be_less_than_current_participants, :validate_location_detail

  belongs_to :person
  belongs_to :group

  belongs_to :location
  accepts_nested_attributes_for :location

  has_many :involvements, :dependent => :destroy

  has_many :participants, :through => :involvements, :source => :person,
                          :conditions => ['involvements.is_pending = ?', false]

  has_many :invitees, :through => :involvements, :source => :person,
                          :conditions => ['involvements.is_pending = ?', true]

  has_many :invitees_plus_participants, :through => :involvements, :source => :person

  has_many :recommendations, :class_name => "EventRecommendation", 
                             :dependent => :destroy, :foreign_key => "item_id"
  has_many :references, :through => :recommendations, :source => :person

  has_many :comments, :class_name => "EventComment", :as => :commentable,
           :dependent => :destroy
  has_many :commentors, :through => :comments, :source => :person

  belongs_to :item, :foreign_key => "subject_id"


  scope :not_started, lambda { where("start_at > ?", Time.now) }
  scope :on_going, lambda { where("start_at <= ? and end_at >= ?", Time.now, Time.now) }
  scope :over, lambda {where("end_at < ?", Time.now)}

  scope :of_item, lambda {|item_id| where('subject_d = ?', item_id)}
  scope :in_items, lambda {|item_ids| where(:subject_id => item_ids)}

  scope :week, lambda { where("start_at > ? and start_at < ?", Time.now.beginning_of_week, Time.now.end_of_week) }
  scope :month, lambda { where("start_at > ? and start_at < ?", Time.now.beginning_of_month, Time.now.end_of_month)}
  scope :today, lambda { where("start_at >= ? and start_at <= ?", Time.now.beginning_of_day, Time.now.end_of_day) }
  scope :weekends, lambda { where("DAYOFWEEK(start_at) = 7 or DAYOFWEEK(start_at) = 1") }
  scope :next_week, lambda { where("start_at >= ? and start_at <= ?", Time.now.next_week, Time.now.next_week.end_of_week) }
  scope :next_month, lambda { where("start_at >= ? and start_at <= ?", Time.now, Time.now.next_month) }
  scope :on_date, lambda {|date| where("start_at >= ? and start_at <= ?", date.beginning_of_day, date.end_of_day )}
  scope :alltime, lambda { select("*") }
  scope :at_city, lambda {|city| includes("location").where(:locations => {:city_id => city}) }
  scope :filter_by_location_and_item, lambda  {|filter| includes("location").where(filter)}


  

  def self.update_avatar_urls(params,url_params)
      event = find(params[:photo][:model_id])
      event.update_attributes(url_params)
  end

  def self.interested_event(city, person)
    item_ids = person.interests.collect {|i| i.id}
    events = Event.in_items(item_ids).week.at_city(city).not_started
    events = Event.in_items(item_ids).month.at_city(city).not_started unless events.size > 0
    events
  end

  def self.hot_event_by_item(city, item)
    events = Event .week.not_started.at_city(city).of_item(item.id)
    events = Event .month.not_started.at_city(city).of_item(item.id) unless events.size > 0
    events = Event .week.at_city(city).of_item(item.id) unless events.size > 0
    events = Event .month.at_city(city).of_item(item.id) unless events.size > 0

    if events.size > 6 
      events = events[0..5] 
    end
  end


  def image_url(size = :thumb_large)
    result = if size == :thumb_medium && self[:image_url_medium]
               self[:image_url_medium]
             elsif size == :thumb_small && self[:image_url_small]
               self[:image_url_small]
             else
               self[:image_url]
             end
    (result != nil && result.length > 0) ? result : default_url(size)
  end
  
  def is_owner(user)
    if user
      return user.person.id == person_id
    else
      false
    end
  end

  def participants_full? 
    self.participants_limit <=  self.participants.size 
  end

  def participants_remained
    self.participants_limit - self.participants.size
  end

  def ongoing?
    self.start_at <= Time.now  && self.end_at > (Time.now)
  end

  def over?
    self.end_at < Time.now
  end

  def not_started?
    self.start_at > Time.now
  end

  def dispatch_event(action,user=self.person.user)
    Dispatch.new(user, self,action).notify_user
  end

  def self.total_event_count
    total_count = Event.count
    count_array = []
       
    while(total_count > 0) 
      count_array << total_count % 10 
      total_count /= 10
    end 
    (4-count_array.size).downto(1) do 
      count_array << 0
    end
    count_array.reverse!
  end

  def subscribers(user,action=false)
    action = action.to_sym
    if action == :delete
      self.participants
    elsif action == :create
      user.befollowed_people
    elsif action == :invite
      self.invited_people
    elsif action == :involvement
      user.befollowed_people
    elsif action == :recommendation
      user.befollowed_people
    end

  end

  def notification_type( action=false )
    action = action.to_sym
    if action == :create
      Notifications::CreateEvent
    elsif action == :delete
      Notifications::DeleteEvent
    elsif action == :invite
      Notifications::InviteEvent
    elsif action == :involvement
      Notifications::InvolvementEvent
    elsif action == :recommendation
      Notifications::RecommendationEvent
    end
  end

  def participants_top(limit)
    participants.order("created_at DESC").limit(limit)
  end

  def references_top(limit)
    references.order("created_at DESC").limit(limit)
  end

  def joinable?
    !(ongoing? || over? || participants_full?)
  end

  def quitable?
    !(ongoing? || over?)
  end

  def owner
    person
  end

  def self.filter_event(conditions)
    filter_hash = {}
    filter_hash[:subject_id] = conditions[:subject_id] unless conditions[:subject_id].nil?
    conditions.delete(:subject_id) 
    time = conditions.delete(:time)
    filter_hash[:locations] = conditions
    if time.nil?
      filter_by_location_and_item(filter_hash)
    else
      filter_by_location_and_item(filter_hash).filter_event_by_time(time)
    end 
  end

  def self.filter_event_by_time(time)
    if (time =~ /\d\d\d\d-\d\d-\d\d/)
      on_date(time.to_date)
    else
      send(time)
    end
  end

  private
    
  def default_url(size)
     case size
        when :thumb_medium then "/images/event/event_medium.jpg"
        when :thumb_large   then "/images/event/event_large.jpg"
        when :thumb_small   then "/images/event/event_small.jpg"
     end
  end
  
  def participants_limit_cannot_be_less_than_current_participants
    if self.participants_limit < self.participants.size
      errors.add(:participants_limit, I18n.t('activerecord.errors.event.participants_limit.     less_than_current'));
    end
  end

  def validate_location_detail
    if location.detail.nil? || location.detail.size == 0
      errors.add(:location, I18n.t('activerecord.errors.event.location.detail_need'));
    end
  end
end
