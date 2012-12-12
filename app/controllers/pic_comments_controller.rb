class PicCommentsController < ApplicationController
  respond_to :js
  def index
    @pic = Pic.find(params[:pic_id])
    if @pic
      @pic_comments = @pic.pic_comments.includes(:author => :profile)
      render :layout => false    
    end
  end

  def show_more
    @pic = Pic.find(params[:pic_id])
    if @pic
      @pic_comments = @pic.pic_comments.includes(:author => :profile)
      render :layout => false    
    end
  end

  def create
    @pic_comment = PicComment.new(:pic_id => params[ :pic_id],:content => params[ :pic_comment ][ :content ],:person_id => current_user.person.id)
    if @pic_comment.save
      if @pic_comment.pic.author.id != current_user.person.id
        @pic_comment.dispatch_pic_comment
      end
    end
    respond_with @pic_comment
  end

  def destroy
    @pic_comment = PicComment.find(params[:id])
    if current_user.person.id == @pic_comment.author.id
      @pic_comment.destroy
      respond_with @pic_comment
    end 
  end
end
