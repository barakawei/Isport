class CommentsController < ApplicationController
  def create
    if params[:comment][:type] == "EventComment"
      @comment = EventComment.create(params[:comment])
    end
    redirect_to :back 
  end
end
