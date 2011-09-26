class StatusMessage < Post
  include ApplicationHelper
  has_many :pics, :dependent => :destroy
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
    if text.rindex("%{")
      form_message = format_pic_upload(text)
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

  def format_pic_upload( text )
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

  def mentioned_people
    if self.persisted?
      create_mentions if self.mentions.empty?
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

  def event_from_string
    regex = /%\{(event);([^\}]+)\}/
    return if self.content.nil?
    id = self.content.scan(regex).map do |match|
      match.last
    end
    id.empty? ? [] : Event.where(:id => id)
  end
end



