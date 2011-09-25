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

  def format_mentions(text)
    regex = /@\{([^;]+); ([^\}]+)\}/
    form_message = text.to_str.gsub(regex) do |matched_string|
      people = self.mentioned_people
      person = people.detect{ |p|
        p.id.to_s == $~[2] unless p.nil?
      }
      person ? person_link_show(person) : ERB::Util.h($~[1])
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
    regex = /@\{([^;]+); ([^\}]+)\}/
    ids = self.contacts.scan(regex).map do |match|
      match.last
    end
    ids.empty? ? [] : Person.where(:id => ids)
  end
end



