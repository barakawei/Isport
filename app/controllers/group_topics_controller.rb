class GroupTopicsController < ApplicationController
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
    @group = Group.find(params[:group_id])
    @topic = Topic.find(params[:id])
    @person = @topic.person

    render 'groups/forum_show_topic'
  end


  def summary
    @group = Group.find(params[:group_id])
    @topic = @group.topics.find(params[:id]) 
    @topic.url = group_topic_path(@group, @topic)
    render :partial => 'topics/summary', :layout => false
  end
end
