class ConversationsController < ApplicationController
  before_filter :registrations_closed?
  before_filter :authenticate_user!,:select_tab

  def select_tab
    @select_tab = 'conversation'
  end

  def index
    @conversations = Conversation.joins(:conversation_visibilities).where(
      :conversation_visibilities => {:person_id => current_user.person.id}).paginate(
      :page => params[:page], :per_page => 5, :order => 'created_at DESC')

    @visibilities = ConversationVisibility.where(:person_id => current_user.person.id).paginate(
      :page => params[:page], :per_page => 5, :order => 'updated_at DESC')

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
    person_ids = Contact.where(:id => params[:contact_ids].split(',')).map! do |contact|
      contact.person_id
    end

    params[:conversation][:participant_ids] = person_ids | [current_user.person.id]
    params[:conversation][:person] = current_user.person
    puts params[ :conversation ]

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
    all_contacts_and_ids = Contact.connection.execute(current_user.contacts.joins(:person => :profile).select("contacts.id, profiles.name,profiles.image_url_small").to_sql).map do |r|
      {:value => r[0],
       :name => r[1].gsub(/(")/, "'"),
       :url => (r[2].nil?) ? '/images/user/default_small.png':r[2]
      }
    end
    @contacts_json = all_contacts_and_ids.to_json.gsub!(/(")/, '\\"')
    @contact = current_user.contacts.find(params[:contact_id]) if params[:contact_id]
    render :layout => false
  end
  
end
