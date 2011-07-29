class GroupsController < ApplicationController
  prepend_before_filter :authenticate_user!, :except => [:index, :show, :forum, :members, :events] 
  before_filter :init, :except => [:index, :show, :forum, :members, :events] 
  
  def index
    city_pinyin = params[:city] ? params[:city] : (current_user ? current_user.city.pinyin : City.first.pinyin)
    @city = City.find_by_pinyin(city_pinyin)
    @groups = Group.all
    @hot_groups = Group.hot_groups(@city).all
    @hot_items = Item.limit(5)
  end

  def show
    @group = Group.find(params[:id])
    @recent_events = @group.events.order('created_at desc').limit(4)
    @members = @group.members.limit(9)
    @current_person = current_user.person if current_user
    @topics = @group.topics.limit(10)
    @topics.each {|t| t.url = group_topic_path(@group, t)}
  end

  def new
    @group = Group.new(:join_mode => 4)
    @group.city = City.first
    
    @step = 1
    @steps = [I18n.t('groups.new_group_wizard.step_1'),I18n.t('groups.new_group_wizard.step_2')]
  end

  def edit
    @group = Group.find(params[:id])
  end

  def edit_members
    @group = Group.find(params[:id])
    @members = @group.deletable_members.order('created_at ASC') || []
    @friends = current_user.friends || [ ] 
    @friend_members = @members & @friends
    @other_members = @members - @friend_members
    @invitees = @group.invitees.order("created_at ASC") || []
    render :action => :edit 
  end


  def create
    @group = Group.new(params[:group])
    current_person = current_user.person
    @group.person = current_person
    @group.forum = Forum.create

    if @group.save
      Membership.create(:group_id => @group.id, :person_id => current_person.id, :is_admin => true)
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
    @invitees.slice!(9, @invitees.length)
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
    @group = Group.find(params[:id])
    @group.destroy

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
    @forum = @group.forum
    @topics = []
    if @forum.topics.count > 0  
      @topics= @forum.topics.paginate :page => params[:page], 
                                      :per_page => 20, :order => 'created_at desc' 
      @topics.each {|t| t.url = group_topic_path(@group, t)}
    end
  end

  def filtered
    city_pinyin = params[:city] ? params[:city] : (current_user ? current_user.city.pinyin : City.first.pinyin)
    @city = City.find_by_pinyin(city_pinyin)
    @district_id = params[:district_id]
    @item_id = params[:item_id]
    search_hash = {:city_id => @city.id}
    search_hash[:item_id] = @item_id unless @item_id.nil?
    search_hash[:district_id] = @district_id unless @district_id.nil?
    @groups = Group.filter_group(search_hash).paginate :page => params[:page], 
                                                       :per_page => 16
  end

  private

  def init
    @current_person = current_user.person    
  end
end
