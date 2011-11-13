class EventCommentsController < ApplicationController
  before_filter :registrations_closed?
  respond_to :js
  def create
    event = Event.find(params[:event_id])
    if params[ :note_type ]
      @comment = event.comments.create(params[:event_comment])
      @comment.person = current_user.person
      @comment.save 
      respond_with @comment
    else
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
  end

  def destroy
    if params[ :note_type ]
      @comment = EventComment.find(params[:id])
      if current_user.person.id == @comment.author.id
        @comment.destroy
        respond_with @comment
      end
    else
      unless params[:response_id].nil?
        event.comments.find(params[:id])
             .responses.find(params[:response_id]).delete
      else
        event.comments.find(params[:id]).delete
      end  
    end
  end

  def index
    @event= Event.find(params[:event_id])
    if @event
      @comments = @event.comments.includes(:author => :profile)
    end
    render :layout => false
  end
end
