class Person < ActiveRecord::Base
  belongs_to :user
  has_many :contacts
  has_many :events
  has_many :involvements, :dependent => :destroy
  has_many :involved_events, :through => :involvements, :source => :event
  has_one :profile
  scope :searchable, joins(:profile) 

  delegate :name, :to => :profile
  delegate :email, :to => :user
  
  def self.search(query,user)
    return [] if query.to_s.blank? || query.to_s.length < 3

    where_clause = <<-SQL
      profiles.name LIKE ? OR
      profiles.name LIKE ?
    SQL
    sql =""
    tokens = []
    query_tokens = query.to_s.strip.split(" ")
    query_tokens.each_with_index do |raw_token,i|
      token = "#{raw_token}%"
      up_token ="#{raw_token.titleize}%"
      sql << " OR " unless i==0
      sql << where_clause
      tokens.concat([token,up_token])
    end
    Person.searchable.where(sql,*tokens)
  end
  
end
