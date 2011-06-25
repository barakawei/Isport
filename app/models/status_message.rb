class StatusMessage < Post
  has_many :photos, :dependent => :destroy
  validate :message_or_photos_present?

  attr_accessible :text

  def as_json(opts={})
    opts ||= {}
    if(opts[:format] == :twitter)
      {
        :id => self.guid,
        :text => self.formatted_message(:plain_text => true),
        :entities => {
            :urls => [],
            :hashtags => self.tag_list,
            :user_mentions => self.mentioned_people.map{|p| p.diaspora_handle},
          },
        :source => 'diaspora',
        :created_at => self.created_at,
        :user => self.author.as_json(opts)
      }
    else
      super(opts)
    end
  end

  protected

  def message_or_photos_present?
    if self.text.blank? && self.photos == []
      errors[:base] << 'Status message requires a message or at least one photo'
    end
  end
end


