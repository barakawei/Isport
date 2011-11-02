class Event < ActiveRecord::Base
  COMMENT_PER_PAGE = 5 
  PARTICIPANTS_LIMIT_MIN = 0 
  PARTICIPANTS_LIMIT_MAX = 100 

  BEING_REVIEWED = 0
  DENIED = 1
  PASSED = 2
  CANCELED_BY_EVENT_ADMIN = 3

  after_save :update_owner_counter
  after_destroy :update_owner_counter
  after_update :update_owner_counter

  attr_accessor :same_day, :current_year,:invited_people, :event_id_before_update

  validates_presence_of :title, :start_at, :description, :subject_id, :participants_limit, :location, 
                        :message => I18n.t('activerecord.errors.messages.blank')
  validates_length_of :title, :maximum => 30
  validates_length_of :description, :maximum => 3000
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
  has_many :albums, :as => :imageable

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
  scope :at_district, lambda {|district_id| includes("location").where(:locations => {:district_id => district_id}) }
  scope :not_full,  lambda { where("participants_count < participants_limit") }
  scope :pass_audit, lambda { where("status = ? ", Event::PASSED ) }  
  scope :to_be_audit, lambda { where("status = ? ", Event::BEING_REVIEWED) }  
  scope :audit_failed, lambda { where("status = ? ", Event::DENIED) } 
  scope :canceled, lambda { where("status = ? ", Event::CANCELED_BY_EVENT_ADMIN) } 
  scope :all, lambda { select("*") }
  scope :open, lambda { where("is_private = ?", false)}
  scope :selected, lambda { where("selected= ?", true)}
  scope :selected_random, lambda { where("selected= ?", true).order('rand()').limit(3)}
  after_destroy :delete_notification

  def delete_notification
    Notification.where(:target_type => self.class.name, :target_id => self.id).delete_all
  end

  def pass
    self.update_attributes(:status => Event::PASSED)
    event_link ="%{event;#{self.id}}"
    content = I18n.t "status_message.pass_event",:event_link => event_link
    @status_message =StatusMessage.initialize(self.person.user,content)
    if @status_message.save
      @status_message.dispatch_post 
    end 
    #invite request
    dispatch_event( :invite )
    
  end

  def reference_event( user )
    event_link ="%{event;#{self.id}}"
    content = I18n.t "status_message.reference_event",:event_link => event_link
    @status_message =StatusMessage.initialize(user,content)
    if @status_message.save
      @status_message.dispatch_post 
    end 
  end

  
  def name
    title
  end

  def self.update_avatar_urls(params,url_params)
      event = find(params[:photo][:model_id])
      event.update_attributes(url_params)
  end

  def self.interested_event(city, person)
    item_ids = person.interests.collect {|i| i.id}
    events = Event.in_items(item_ids).week.at_city(city).not_started.not_full.visable.order('start_at').limit(6)
    events = Event.in_items(item_ids).month.at_city(city).not_started.not_full.visable.order('start_at').limit(6) unless events.size > 0
    events = Event.in_items(item_ids).next_month.at_city(city).not_started.not_full.visable.order('start_at').limit(6) unless events.size > 0
    events
  end

  def self.recent_events(city)
    events = Event.at_city(city.id).not_started.visable.order('start_at').limit(50)
    size = events.size
    events.sort_by{rand}[0..6]
  end
  
  def self.visable
    open.pass_audit 
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

  def dispatch_event(action,user=self.person.user)
    Dispatch.new(user, self,action).notify_user
  end

  def subscribers(user,action=false)
    action = action.to_sym
    if action == :delete
      self.participants
    elsif action == :create
      user.befollowed_people
    elsif action == :invite
      self.invitees
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
    time = conditions[:time]
    city = conditions[:city_id]
    district = conditions[:district_id]
    subject = conditions[:subject_id]
    
    if district && subject 
      at_city(city).at_district(district).of_item(subject).filter_event_by_time(time).pass_audit
    elsif district.nil? && !subject.nil?
      at_city(city).of_item(subject).filter_event_by_time(time).pass_audit
    elsif !district.nil? && subject.nil?
      at_city(city).at_district(district).filter_event_by_time(time).pass_audit
    else 
      at_city(city).filter_event_by_time(time).pass_audit
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

  def weibo_image_file
    url = self.image_url ? self.image_url : default_url(:thumb_large)  
    url =  Rails.root.to_s + "/public#{url}" 
    File.new(url)
  end

  def weibo_status(url)
    str = I18n.t('events.weibo_status', {:type => self.item.name,
                 :name => self.name, :time => I18n.l(self.start_at, :format => :long),
                 :location => self.location.to_s, :url => url})
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
    if self.subject_id_was && self.subject_id_was != self.subject_id
      begin
        i = Item.find(self.subject_id_was)
        i.events_count = i.events.count
        i.save
      rescue Exception
      end
    end
    self.item.events_count = self.item.events.count
    self.item.save
  
    if self.group
      if self.group_id_was && self.group_id_was != self.group_id
        begin
          g = Group.find(self.group_id_was)
          g.events_count = g.events.count
          g.save
        rescue Exception
        end
      end
      self.group.events_count = self.group.events.count
      self.group.save
    end
  end
end
