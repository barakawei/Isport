class ConversationsController < ApplicationController
  before_filter :registrations_closed?
  before_filter :authenticate_user!,:select_tab

  def select_tab
    @select_tab = 'conversation'
  end

  def index
    @conversations = Conversation.joins(:conversation_visibilities).where(
      :conversation_visibilities => {:person_id => current_user.person.id}).paginate(
      :page => params[:page], :per_page => 10, :order => 'updated_at DESC')

    @visibilities = ConversationVisibility.where(:person_id => current_user.person.id).paginate(
      :page => params[:page], :per_page => 10, :order => 'updated_at DESC')

    @unread_counts = {}
    @visibilities.each { |v| @unread_counts[v.conversation_id] = v.unread }

    @authors = {}
    @conversations.each { |c| @authors[c.id] = c.last_author }

    if @conversation = Conversation.joins(:conversation_visibilities).where(
      :conversation_visibilities => {:person_id => current_user.person.id, :conversation_id => params[:conversation_id]}).first
      if @visibility = ConversationVisibility.where(:conversation_id => params[:conversation_id], :person_id => current_user.person.id).first
        @visibility.unread = 0
        @visibility.save
      end
    end 
    @unread_message_count = ConversationVisibility.sum(:unread, :conditions => "person_id = #{current_user.person.id}")
    @select_tab = 'conversation'
  end

  def create
    person_ids = params[ :person_ids].split( ',' )
    params[:conversation][:participant_ids] = person_ids | [current_user.person.id]
    params[:conversation][:person] = current_user.person

    if @conversation = Conversation.create(params[:conversation])
      if params[:profile]
        redirect_to person_path(params[:profile])
      else
        redirect_to conversations_path(:conversation_id => @conversation.id)
      end
    end
  end

  def show
    if @conversation = Conversation.joins(:conversation_visibilities).where(:id => params[:id],:conversation_visibilities => {:person_id => current_user.person.id}).first
      if @visibility = ConversationVisibility.where(:conversation_id => params[:id], :person_id => current_user.person.id).first
        @visibility.unread = 0
        @visibility.save
      end
      render :layout => false
    else
      redirect_to conversations_path
    end
  end

  def new
    people_hash ={}
    Contact.connection.execute(current_user.contacts.joins(:person => :profile).select("people.id, profiles.name,profiles.image_url_small").to_sql).each do |r|
      people_hash[r[0]] = {:value => r[0],
       :name => r[1].gsub(/(")/, "'"),
       :url => (r[2].nil?) ? '/images/user/default_small.png':r[2],
       :filled => false
      }
    end
    person_hash={  }
    Person.connection.execute(Person.joins(:profile).select("people.id, profiles.name,profiles.image_url_small").where(:id => params[:person_ids]).to_sql).each do |r|
      person_hash[r[0]]= {:value => r[0],
       :name => r[1].gsub(/(")/, "'"),
       :url => (r[2].nil?) ? '/images/user/default_small.png':r[2],
       :filled => true
      }
    end
    people_hash.merge!( person_hash )
    people_array = [  ]
    people_hash.each_value {|value| people_array.push( value )  } 
    @people_json = people_array.to_json.gsub!(/(")/, '\\"')
    render :layout => false
  end
  
end
