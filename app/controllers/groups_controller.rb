class GroupsController < ApplicationController
  before_filter :registrations_closed?
  prepend_before_filter :authenticate_user!, :except => [:index, :show, :forum, :members, :events, :filtered] 
  before_filter :init, :except => [:index, :show, :forum, :members, :events, :filtered]
  before_filter :authenticate_admin!, :only => [:edit, :edit_members, :invite_friends, :update]
  before_filter :is_owner, :only => [:edit, :edit_members, :update, :invite_friends]                 
  
  def index
    city_id = params[:city] ? params[:city] : (current_user ? current_user.city.id : City.first.id)
    @city = City.find_by_id(city_id)
    @hot_groups = current_user ? Group.interested_groups(@city,current_user.person) : []
    @hot_items = Item.hot_items(5, current_user.person.location.city)
    @select_tab = 'group'
  end

  def show
    @group = Group.find(params[:id])
    if @group.in_audit_process? && !@group.is_owner(current_user) && !current_user.try(:admin?)
      render 'common/in_audit', :locals => {:type => I18n.t('groups_link'), 
              :link_content => I18n.t('groups.other_groups'), :path => groups_path}
    end
    @recent_events = @group.events.order('created_at desc').limit(4)
    @members = @group.members.limit(9)
    @current_person = current_user.person if current_user
    @topics = @group.topics.limit(10)
    @topics.each {|t| t.url = group_topic_path(@group, t)}

    @event_size  = @group.events.count
    @topic_size = @group.topics.count
    @member_size = @group.members.count
    @is_member = @group.has_member?(@current_person) if @current_person
  end

  def new
    auth = current_user.authorizations.first
    @is_binded = !auth.nil?
    @group = Group.new(:join_mode => Group::JOIN_FREE)
    @group.city = current_user.person.location.city 
    @friends = current_user.friends
    @step = 1
    @steps = [I18n.t('groups.new_group_wizard.step_1'),I18n.t('groups.new_group_wizard.step_2')]
  end

  def edit
    @new = true if params[:new] == 'new'
    @group = Group.find(params[:id])
  end

  def apply_reaudit
    @group = Group.find(params[:id])
    if @group.status == Group::DENIED && @group.is_owner(current_user)
      @group.update_attributes(:status => Group::BEING_REVIEWED, :status_msg => "");
    end
    redirect_to :back
  end     

  def edit_members
    @current_person = current_user.person
    @group = Group.find(params[:id])
    if @group.person == @current_person 
      @members = @group.members
      @members -= [@current_person]
    else
      @members = @group.deletable_members.order('created_at ASC') || []
    end
    @friends = current_user.friends || [ ] 
    @invitees = @group.invitees.order("created_at ASC") || []
    @applicants = @group.applicants.order("created_at ASC") || []
    puts @applicants.size
    @friend_members = @members & @friends
    render :action => :edit 
  end


  def create
    @group = Group.new(params[:group])
    current_person = current_user.person
    @group.person = current_person
    @group.forum = Forum.create
    auth = current_user.authorizations.first

    if @group.save
      @group.memberships.create(:person_id => current_person.id, :is_admin => true)
      if params['sina_weibo'] == 'yes' && auth
        auth.create_weibo_with_photo(@group.weibo_status(group_path(@group)), @group.weibo_image_file)
      end
      redirect_to new_group_invite_path(@group)
    else
      @step = 1
      @steps = [I18n.t('groups.new_group_wizard.step_1'),I18n.t('groups.new_group_wizard.step_2')]
      render :action => :new
    end
  end

  def invite_friends
    @group = Group.find(params[:id])
    @invitees = @group.invitees
    @invitees_size = @invitees.size
    @friends = current_user.friends
    @to_be_invited_friends = @friends - @group.related_person || []
    @invitees
    @step = 2
    @steps = [I18n.t('groups.new_group_wizard.step_1'),I18n.t('groups.new_group_wizard.step_2')]
    render :action => "new" 
  end

  def update
    @group = Group.find(params[:id])

    respond_to do |format|
      if @group.update_attributes(params[:group])
        format.html { redirect_to(@group, :notice => 'Group was successfully updated.') }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  def destroy
    redirect_to(groups_url) 
  end

  def members
    @group = Group.find(params[:id])
    @members = @group.members.paginate :page => params[:page], :per_page => 10
  end

  def events
    @group = Group.find(params[:id])
    @events = @group.events.order('start_at desc').paginate :page => params[:page],
                                                            :per_page => 10
  end

  def forum
    @group = Group.find(params[:id])
    if @group.in_audit_process? && !@group.is_owner(current_user) && !current_user.try(:admin?)
      render 'common/in_audit', :locals => {:type => I18n.t('groups_link'), 
              :link_content => I18n.t('groups.other_groups'), :path => groups_path}
    end
    @forum = @group.forum
    @topics = []
    if @forum.topics.count > 0  
      @topics= @forum.topics.paginate :page => params[:page], 
                                      :per_page => 20, :order => 'created_at desc' 
      @topics.each {|t| t.url = group_topic_path(@group, t)}
    end
  end

  def filtered
    city_id = params[:city] ? params[:city] : (current_user ? current_user.city.id : City.first.id)
    @city = City.find_by_id(city_id)
    @district_id = params[:district_id]
    @item_id = params[:item_id]
    search_hash = {:city_id => @city.id}
    search_hash[:item_id] = @item_id unless @item_id.nil?
    search_hash[:district_id] = @district_id unless @district_id.nil?
    @groups = Group.filter_group(search_hash).pass_audit.paginate :page => params[:page], 
                                                       :per_page => 16
    @select_tab = 'group'
  end

  private

  def is_owner
    unless @group.is_owner(current_user)
     redirect_to group_path(@event) 
    end
  end

  def init
    @current_person = current_user.person    
  end

  def authenticate_admin!  
    @group = Group.find(params[:id])
    unless @group.is_admin(@current_user.person) 
      redirect_to group_path(@group) 
    end
  end
end
