class Event < ActiveRecord::Base
  COMMENT_PER_PAGE = 5 

  attr_accessor :same_day, :current_year
  validates_presence_of :title, :start_at, :description, :location, :subject_id,
                        :message => I18n.t('activerecord.errors.messages.blank')
  
  validates_length_of :title, :maximum => 30
  validates_length_of :description, :maximum => 800
  validates :start_at, :date => { :after => Proc.new { Time.now }, 
                                  :message => I18n.t('activerecord.errors.event.start_at.after')} 
                       
  validates :end_at, :date => { :after => :start_at,
                                :message => I18n.t('activerecord.errors.event.end_at.after')}


  belongs_to :person
  has_many :involvements, :dependent => :destroy
  has_many :participants, :through => :involvements, :source => :person

  has_many :recommendations, :class_name => "EventRecommendation", 
                             :dependent => :destroy, :foreign_key => "item_id"
  has_many :references, :through => :recommendations, :source => :person


  has_many :comments, :class_name => "EventComment",
           :dependent => :destroy, :foreign_key => "item_id"
  has_many :commentors, :through => :comments, :source => :person

  belongs_to :item, :foreign_key => "subject_id"

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

  private
    
  def default_url(size)
     case size
        when :thumb_medium then "/images/event/event_medium.jpg"
        when :thumb_large   then "/images/event/event_large.jpg"
        when :thumb_small   then "/images/event/event_small.jpg"
     end
  end
end

