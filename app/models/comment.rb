class Comment < ActiveRecord::Base
  include ApplicationHelper
  belongs_to :author,:foreign_key => :person_id,:class_name => "Person"
  belongs_to :post,:touch => true
  attr_accessor :contacts
  has_many :mentions
  after_create :create_mentions

  def dispatch_comment(user=self.author.user)
    Dispatch.new(user, self).notify_user
  end

  def subscribers(user,action=false)
    [self.post.author]
  end

  def notification_type( action=false )
    Notifications::StatusComment
  end

  def format_message(text)
    return if text.nil?
    if text.rindex("@{")
      form_message = format_mention(text)
    else
      form_message = text
    end
    form_message
  end

  def mention?
    if self.contacts.rindex("@{")
      true
    else
      false
    end
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

  def create_mentions
    people = mentioned_people_from_string
    people.each do |person|
      mention = self.mentions.new(:person => person)
      if mention.save
        mention.dispatch_mention
      end
    end
  end

  def mentioned_people_from_string
    regex = /@\{([^;]+);([^\}]+)\}/
    return if self.contacts.nil?
    ids = self.contacts.scan(regex).map do |match|
      match.last
    end
    ids.empty? ? [] : Person.where(:id => ids)
  end

  def mentioned_people
    if self.persisted?
      self.mentions.map{ |mention| mention.person }
    else
      mentioned_people_from_string
    end
  end

end
