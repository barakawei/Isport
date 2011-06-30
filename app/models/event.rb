class Event < ActiveRecord::Base
  COMMENT_PER_PAGE = 5 
  SORT_BY_STARTTIME = "by_starttime"
  SORT_BY_POPULARITY= "by_popularity"
  PARTICIPANTS_LIMIT_MIN = 0
  PARTICIPANTS_LIMIT_MAX = 100 

  attr_accessor :same_day, :current_year
  validates_presence_of :title, :start_at, :description, :location, :subject_id,
                        :participants_limit,
                        :message => I18n.t('activerecord.errors.messages.blank')
  
  validates_length_of :title, :maximum => 30
  validates_length_of :description, :maximum => 800
  validates_numericality_of :participants_limit, :only_integer => true,
                            :greater_than => PARTICIPANTS_LIMIT_MIN,
                            :less_than_or_equal_to => PARTICIPANTS_LIMIT_MAX

  validates :end_at, :date => { :after => :start_at,
                                :message => I18n.t('activerecord.errors.event.end_at.after')}

  validate :participants_limit_cannot_be_less_than_current_participants

  belongs_to :person
  has_many :involvements, :dependent => :destroy

  has_many :participants, :through => :involvements, :source => :person,
                          :conditions => ['involvements.is_pending = ?', false]

  has_many :invitees, :through => :involvements, :source => :person,
                          :conditions => ['involvements.is_pending = ?', true]

  has_many :invitees_plus_participants, :through => :involvements, :source => :person

  has_many :recommendations, :class_name => "EventRecommendation", 
                             :dependent => :destroy, :foreign_key => "item_id"
  has_many :references, :through => :recommendations, :source => :person

  has_many :comments, :class_name => "EventComment",
           :dependent => :destroy, :foreign_key => "item_id"
  has_many :commentors, :through => :comments, :source => :person

  belongs_to :item, :foreign_key => "subject_id"

  scope :week, lambda { where("start_at > ? and start_at < ?", Time.now.beginning_of_week,
                             Time.now.end_of_week) }

  scope :today, lambda { where("start_at >= ? and start_at <= ?", Time.now.beginning_of_day, Time.now.end_of_day) }
  scope :weekends, lambda {where("DAYOFWEEK(start_at) = 7 or DAYOFWEEK(start_at) = 1") }
  scope :on_date, lambda {|date| where("start_at >= ? and start_at <= ?", date.beginning_of_day, date.end_of_day )}
  scope :alltime, lambda { select("*") }

  def self.update_avatar_urls(params,url_params)
      event = find(params[:photo][:model_id])
      puts event.update_attributes(url_params)
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
  
  def paginated_comments(page)
    @comments = self.comments.order("created_at ASC")
    total_pages = @comments.size / COMMENT_PER_PAGE 
    if page == nil
      if @comments.size % COMMENT_PER_PAGE != 0 || total_pages == 0
        total_pages += 1
      end
      page = total_pages 
    end
    
    paged_comments = @comments.paginate(:page => page,
                                         :per_page => COMMENT_PER_PAGE) 
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

  def dispatch_event( action=false )
    Dispatch.new(self.person.user, self,action).notify_user
  end

  def subscribers(user,action=false)
    if action == :delete
      self.participants
    elsif action == :create
      user.followed_people
    end
  end

  def notification_type( action )
    if action == :create
      Notifications::CreateEvent
    elsif action == :delete
      Notifications::DeleteEvent
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
end
