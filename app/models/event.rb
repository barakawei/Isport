class Event < ActiveRecord::Base
  validates_presence_of :title, :start_at, :description, :location, 
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

  def self.update_avatar_urls(params,url_params)
      event = find(params[:photo][:model_id])
      event.update_attributes(url_params)   
  end

  def image_url(size = :thumb_large)
    result = if size == :thumb_medium && self[:image_url_medium]
               self[:image_url_medium]
             elsif size == :thumb_small && self[:image_url_small]
               self[:image_url_small]
             else
               self[:image_url]
             end
    result || '/images/user/default.png'
  end
  
  def image_url= url
    return image_url if url == ''
    if url.nil? || url.match(/^https?:\/\//)
      super(url)
    else
    end
  end

  def image_url_small= url
    return image_url if url == ''
    if url.nil? || url.match(/^https?:\/\//)
      super(url)
    else
    end
  end

  def image_url_medium= url
    return image_url if url == ''
    if url.nil? || url.match(/^https?:\/\//)
      super(url)
    else
    end
  end

  def is_owner(user)
    if user
      return user.person.id == person_id
    else
      false
    end
  end
end

