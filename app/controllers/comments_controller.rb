class CommentsController < ApplicationController
  respond_to :js
  def create
    if params[:comment][:type] == "EventComment"
      @comment = EventComment.create(params[:comment])
      redirect_to "/events/#{@comment.item_id}#comments"  
    end

    puts current_user
    @comment = Comment.new(:post_id => params[ :status_message_id ],:content => params[ :comment ][ :content ],:person_id => current_user.person.id)
    if @comment.save
      respond_with @comment
    end

  end
end
