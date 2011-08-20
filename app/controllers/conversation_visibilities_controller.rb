class ConversationVisibilitiesController < ApplicationController
  before_filter :registrations_closed?
  before_filter :authenticate_user!

  def destroy
    @vis = ConversationVisibility.where(:person_id => current_user.person.id,
                                        :conversation_id => params[:conversation_id]).first
    if @vis
      if @vis.destroy
      end
    end
    redirect_to conversations_path
  end
  
end
