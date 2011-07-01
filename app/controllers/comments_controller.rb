class CommentsController < ApplicationController
  respond_to :js
  def create
    if params[:comment][:type] == "EventComment"
      @comment = EventComment.create(params[:comment])
      if @comment.save
        render :template => "comments/create_event_comment"
      end
    else
      @comment = Comment.new(:post_id => params[ :status_message_id ],:content => params[ :comment ][ :content ],:person_id => current_user.person.id)
      if @comment.save
        respond_with @comment
      end
    end
  end
end
