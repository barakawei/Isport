class StatusMessage < Post
  include ApplicationHelper
  include AlbumsHelper
  has_many :pics, :dependent => :destroy
  has_one :post_video, :dependent => :destroy
  attr_accessible :content
  attr_accessor :contacts
  after_create :create_mentions

  def self.initialize( user,content)
    status_message = StatusMessage.new
    status_message.author = user.person
    status_message.content = content
    status_message.contacts = content
    status_message

  end

  def format_message(text)
    if text.rindex("%{event")
      form_message = format_event(text)
    elsif text.rindex("%{album")
      form_message = format_album(text)
    elsif text.rindex("@{")
      form_message = format_mention(text)
    else
      form_message = text
    end
    form_message
  end

  def format_mention( text )
    regex = /@\{([^;]+);([^\}]+)\}/
    form_message = text.to_str.gsub(regex) do |matched_string|
      people = self.mentioned_people
      person = people.detect{ |p|
        p.id.to_s == $~[2] unless p.nil?
      }
      person ? person_link_show(person) : ERB::Util.h($~[1])
    end
    form_message
  end

  def format_4_weibo(text)
    regex = /@\{([^;]+);([^\}]+)\}/
    form_message = text.to_str.gsub(regex) do |matched_string|
      "@#{$~[1]} "
    end
    form_message 
  end

  def format_event( text )
    regex = /%\{([^;]+);([^\}]+)\}/
    form_message = text.to_str.gsub(regex) do |matched_string|
      events = self.event_from_string
      event = events.detect{ |p|
        p.id.to_s == $~[2] unless p.nil?
      }
      event ? event_link(event) : ""
    end
    form_message
  end

  def format_album( text )
    regex = /%\{([^;]+);([^\}]+)\}/
    form_message = text.to_str.gsub(regex) do |matched_string|
      albums = self.album_from_string
      album = albums.detect{ |a|
        a.id.to_s == $~[2] unless a.nil?
      }
      album ? album_link(self.author,album) : ""
    end
    form_message
  end

  def mentioned_people
    if self.persisted?
      self.mentions.map{ |mention| mention.person }
    else
      mentioned_people_from_string
    end
  end

  def create_mentions
    people = mentioned_people_from_string
    people.each do |person|
      mention = self.mentions.new(:person => person)
      if mention.save
        mention.dispatch_mention
      end
    end
  end

  def mentions?(person)
    mentioned_people.include? person
  end

  def notify_person(person)
    self.mentions.where(:person_id => person.id).first.try(:notify_recipient)
  end

  def mentioned_people_from_string
    regex = /@\{([^;]+);([^\}]+)\}/
    return if self.contacts.nil?
    ids = self.contacts.scan(regex).map do |match|
      match.last
    end
    ids.empty? ? [] : Person.where(:id => ids)
  end

  def weibo_status(url="")
    if item_topic
      topic_name = '#'+item_topic.name+ "#    "
      topic_url = "  " + url+"#{self.item_topic_id}"
      size = 140 - topic_name.size - topic_url.size
      topic_content = format_4_weibo(self.content)[0..size-1]
      topic_name + topic_content + topic_url 
    else
      format_4_weibo(self.content)[0..139]
    end
  end

  def event_from_string
    regex = /%\{(event);([^\}]+)\}/
    return if self.content.nil?
    id = self.content.scan(regex).map do |match|
      match.last
    end
    id.empty? ? [] : Event.where(:id => id)
  end

  def album_from_string
    regex = /%\{(album);([^\}]+)\}/
    return if self.content.nil?
    id = self.content.scan(regex).map do |match|
      match.last
    end
    id.empty? ? [] : Album.where(:id => id)
  end

  def create_video
    links = get_content_links 
    links.each do |link|
      if  !link.index("v.youku.com").nil? 
        doc = Hpricot(open(link))
        l = (doc/'a[@id="s_sina"]')
        v = (doc/'[@id="link2"]')  
        if l && v
          href = l.attr('href')
          pos = href.index("pic=")
          length = href.length
          p_add = href[(pos+4)..length]
          v_add = v.attr('value')
          self.post_video = PostVideo.create(:href => v_add, :thumb_href => p_add)
          break
        end
      end
    end
  end

  private

  def get_content_links
    result = []
    regex = /https?:\/\/[^\s\u4e00-\u9fa5]+/
    t_string = self.content.clone
    while a=regex.match(t_string) do
        result << a[0]
        t_string.sub!(regex, '')
    end
    result
  end
end



