class Event < ActiveRecord::Base
  COMMENT_PER_PAGE = 5 
  PARTICIPANTS_LIMIT_MIN = 0 
  PARTICIPANTS_LIMIT_MAX = 100 

  BEING_REVIEWED = 0
  DENIED = 1
  PASSED = 2
  CANCELED_BY_EVENT_ADMIN = 3

  attr_accessor :same_day, :current_year,:invited_people

  validates_presence_of :title, :start_at, :description, :subject_id, :participants_limit, :location, 
                        :message => I18n.t('activerecord.errors.messages.blank')
  validates_length_of :title, :maximum => 30
  validates_length_of :description, :maximum => 2000
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
  belongs_to :item, :foreign_key => "subject_id"
  belongs_to :audit_person, :foreign_key => "audit_person_id", :class_name => 'Person'

  has_many :involvements, :dependent => :destroy
  has_many :participants, :through => :involvements, :source => :person,
                          :conditions => ['involvements.is_pending = ?', false]
  has_many :invitees,  :through => :involvements, :source => :person,
                          :conditions => ['involvements.is_pending = ?', true]
  has_many :invitees_plus_participants, :through => :involvements, :source => :person
  has_many :recommendations, :class_name => "EventRecommendation", 
                             :dependent => :destroy, :foreign_key => "item_id"
  has_many :references, :through => :recommendations, :source => :person
  has_many :comments, :class_name => "EventComment", :as => :commentable, :dependent => :destroy
  has_many :commentors, :through => :comments, :source => :person



  scope :not_started, lambda { where("start_at > ?", Time.now) }
  scope :on_going, lambda { where("start_at <= ? and end_at >= ?", Time.now, Time.now) }
  scope :over, lambda {where("end_at < ?", Time.now)}
  scope :of_item, lambda {|item_id| where('subject_id = ?', item_id)}
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
  scope :not_full,  lambda { where("participants_count < participants_limit") }


  def self.update_avatar_urls(params,url_params)
      event = find(params[:photo][:model_id])
      event.update_attributes(url_params)
  end

  def self.interested_event(city, person)
    item_ids = person.interests.collect {|i| i.id}
    events = Event.in_items(item_ids).week.at_city(city).not_started.not_full.order('start_at')
    events = Event.in_items(item_ids).month.at_city(city).not_started.not_full.order('start_at') unless events.size > 0
    events = Event.in_items(item_ids).next_month.at_city(city).not_started.not_full.order('start_at') unless events.size > 0
    events
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
    user && user.person.id == person_id
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

  def need_notice?
    status == Event::BEING_REVIEWED || status == Event::DENIED || status == Event::CANCELED_BY_EVENT_ADMIN 
  end

  def in_audit_process?
    status == Event::BEING_REVIEWED || status == Event::DENIED
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
      errors.add(:participants_limit, I18n.t('activerecord.errors.event.participants_limit.less_than_current'));
    end
  end

  def validate_location_detail
    if location.nil? || location.detail.nil? || location.detail.size == 0
      errors.add(:location, I18n.t('activerecord.errors.event.location.detail_need'));
    end
  end

  def update_owner_counter
    self.item.events_count = self.item.events.count
    self.item.save
  
    if self.group
      self.group.events_count = self.group.events.count
      self.group.save
    end
  end
end
