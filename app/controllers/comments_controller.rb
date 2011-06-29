class CommentsController < ApplicationController
  def create
    if params[:comment][:type] == "EventComment"
      @comment = EventComment.create(params[:comment])
      redirect_to "/events/#{@comment.item_id}#comments"  
    end
  end
end
