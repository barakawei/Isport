class EventCommentsController < ApplicationController
  def create
    event = Event.find(params[:event_id])
    if params[:comment]
      commentable = event.comments.find(params[:comment][:commentable_id])
      c = commentable.responses.create(params[:comment]) 
      c.person = current_user.person
      c.save
      render :partial => 'events/response', :locals => {:person => current_user.person, :comment => c,
                                                        :commentable => commentable}
    else
      c = event.comments.create(params[:event_comment])
      c.person = current_user.person
      c.save 
      render :partial => 'events/comment', :locals => {:person => current_user.person, :comment => c}
    end
  end
end
