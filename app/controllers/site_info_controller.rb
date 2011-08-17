class SiteInfoController < ApplicationController
  before_filter :authenticate_user!
  
  def feedback
    @succ = true if params[:succ] and params[:succ] == 'true'
    @feedback = Feedback.new
  end

  def create_feedback
    @feedback = Feedback.new(params[:feedback])
    @feedback.person_id = current_user.person.id
    @feedback.save
    redirect_to new_feedback_path(:succ => true) 
  end

end
