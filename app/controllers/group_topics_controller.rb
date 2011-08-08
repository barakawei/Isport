class GroupTopicsController < ApplicationController
  before_filter :authenticate_user!, :except => [:show, :summary]
 
  def new
    current_person = current_user.person
    @group = Group.find(params[:group_id])
    @forum = @group.forum

    @topic = Topic.new(:forum_id => @forum.id,
                       :person_id => current_person.id)
    @current = 'forum'
    render 'groups/forum_new_topic'
  end

  def create
    @group = Group.find(params[:group_id])
    @topic = Topic.new(params[:topic])
    @topic.forum = @group.forum
    @topic.person = current_user.person

    if @topic.save
      redirect_to forum_group_path(@group) 
    else
      render 'groups/forum_new_topic'
    end
  end

  def show
    page = params[:page].to_i
    @only_comment = (page > 1)
    @group = Group.find(params[:group_id])
    @topic = Topic.find(params[:id])
    @comments = []
    if @topic.comments.size > 0 
      @comments =  @topic.comments.paginate :page => params[:page], 
                                          :per_page => 15, :order => 'created_at'
    end
    @person = @topic.person
    @current_person = current_user.person if current_user
    @new_comment = @topic.comments.new(:content => "")

    render 'groups/forum_show_topic'
  end


  def summary
    @group = Group.find(params[:group_id])
    @topic = @group.topics.find(params[:id]) 
    @topic.url = group_topic_path(@group, @topic)
    render :partial => 'topics/summary', :layout => false
  end
end
