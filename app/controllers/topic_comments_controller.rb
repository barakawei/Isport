class TopicCommentsController < ApplicationController
  before_filter :registrations_closed?
  def create
    topic = Topic.find(params[:topic_id]) 
    if params[:comment]
      commentable = topic.comments.find(params[:comment][:commentable_id])
      c = commentable.responses.create(params[:comment]) 
      c.person = current_user.person
      if c.save
        c.dispatch_topic_comment
      end
      render :partial => 'topics/response', :locals => {:person => current_user.person, :comment => c,
                                                        :commentable => commentable, :topic => topic}
    else
      c = topic.comments.create(params[:topic_comment])
      c.person = current_user.person
      c.save
      render :partial => 'topics/comment', :locals => {:person => current_user.person, :comment => c, :topic => topic}
    end
  end
  
  def destroy
    topic = Topic.find(params[:topic_id])
    unless params[:response_id].nil?
      topic.comments.find(params[:id])
           .responses.find(params[:response_id]).delete
    else
      topic.comments.find(params[:id]).delete
    end
    redirect_to :back
  end
end
