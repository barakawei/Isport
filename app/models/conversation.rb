class Conversation < ActiveRecord::Base
  has_many :conversation_visibilities, :dependent => :destroy
  has_many :participants, :class_name => 'Person', :through => :conversation_visibilities, :source => :person
  has_many :messages, :order => 'created_at ASC'
  belongs_to :person

  def self.create(opts={})
    opts = opts.dup
    msg_opts = {:person => opts[:person], :text => opts.delete(:text)}
    cnv = super(opts)
    message = Message.new(msg_opts.merge({:conversation_id => cnv.id}))
    if message.save
      ConversationVisibility.connection.execute(" update conversation_visibilities set unread= unread +1 where conversation_id ="+cnv.id.to_s+" and person_id !="+opts[:person].id.to_s  );
    end
    cnv
  end
  
  
  def last_author
    self.messages.last.person if self.messages.size > 0
  end

  def subject
    self[:subject].blank? ? "" : self[:subject]
  end
  
end
