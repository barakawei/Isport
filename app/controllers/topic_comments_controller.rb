class TopicCommentsController < ApplicationController
  def create
    topic = Topic.find(params[:topic_id]) 
    if params[:comment]
      commentable = topic.comments.find(params[:comment][:commentable_id])
      c = commentable.responses.create(params[:comment]) 
      c.person = current_user.person
      c.save
      render :partial => 'topics/response', :locals => {:person => current_user.person, :comment => c,
                                                        :commentable => commentable}
    else
      c = topic.comments.create(params[:topic_comment])
      c.person = current_user.person
      c.save
      render :partial => 'topics/comment', :locals => {:person => current_user.person, :comment => c}
    end
  end
end
