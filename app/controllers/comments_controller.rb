class CommentsController < ApplicationController
  before_filter :registrations_closed?
  respond_to :js
  def create
    @comment = Comment.new(:post_id => params[ :status_message_id ],:content => params[ :comment ][ :content ],:person_id => current_user.person.id)
    if @comment.save
      respond_with @comment
    end
  end

  def index
    @post = Post.find(params[:post_id])
    if @post
      @comments = @post.comments.includes(:author => :profile)
      render :layout => false    
    end
  end

  def destroy
    @comment = Comment.find(params[:id])
    if current_user.person.id == @comment.author.id
      @comment.destroy
      respond_with @comment
    end 
  end
end
