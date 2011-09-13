class PicCommentsController < ApplicationController
  respond_to :js
  def index
    @pic = Pic.find(params[:pic_id])
    if @pic
      @pic_comments = @pic.pic_comments.includes(:author => :profile)
      render :layout => false    
    end
  end

  def create
    @pic_comment = PicComment.new(:pic_id => params[ :pic_id],:content => params[ :pic_comment ][ :content ],:person_id => current_user.person.id)
    @pic_comment.save
    respond_with @pic_comment
  end

  def destroy
  end
end
