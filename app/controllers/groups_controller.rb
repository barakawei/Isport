class GroupsController < ApplicationController
  prepend_before_filter :authenticate_user!, :except => [:index, :show] 
  before_filter :init, :except => [:index, :show] 
  
  def index
    @groups = Group.all
  end

  def show
    @group = Group.find(params[:id])
    @members = @group.members.limit(9)
    @current_person = current_user.person
  end

  def new
    @group = Group.new
  end

  def edit
    @group = Group.find(params[:id])
  end

  def create
    @group = Group.new(params[:group])
    @group.person = current_user.person
    @group.members << current_user.person
    @group.forum = Forum.create

    respond_to do |format|
      if @group.save
        format.html { redirect_to(@group, :notice => 'Group was successfully created.') }
      else
        format.html { render :action => "new" }
      end
    end
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

  def forum
    @group = Group.find(params[:id])
    @forum = @group.forum
    @topics = []
    if @forum.topics.count > 0  
      @topics= @forum.topics.paginate :page => params[:page], 
                                      :per_page => 20, :order => 'created_at desc' 
      @topics.each {|t| t.url = topic_summary_path(:group_id => @group.id, :id => t.id)}
    end
  end

  private

  def init
    @current_person = current_user.person    
  end
end
