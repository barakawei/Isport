class EventCommentsController < ApplicationController
  before_filter :registrations_closed?
  def create
    event = Event.find(params[:event_id])
    if params[:comment]
      commentable = event.comments.find(params[:comment][:commentable_id])
      c = commentable.responses.create(params[:comment]) 
      c.person = current_user.person
      if c.save
        c.dispatch_event_comment
      end
      render :partial => 'events/response', :locals => {:person => current_user.person, :comment => c,
                                                        :commentable => commentable, :event => event}
    else
      c = event.comments.create(params[:event_comment])
      c.person = current_user.person
      c.save 
      render :partial => 'events/comment', :locals => {:person => current_user.person, :comment => c, :event => event}
    end
  end

  def destroy
    event = Event.find(params[:event_id])
    unless params[:response_id].nil?
      event.comments.find(params[:id])
           .responses.find(params[:response_id]).delete
    else
      event.comments.find(params[:id]).delete
    end  
  end
end
