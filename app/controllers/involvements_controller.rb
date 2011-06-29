class InvolvementsController < ApplicationController
   def destroy
    member_ids = params[:member_ids].split(',');
    @event = Event.find(params[:event_id]) 
  
    unless @event.nil? && member_id.nil?
      member_ids.each {|id| Involvement.where(:event_id => @event.id, :person_id => id).first.destroy}
    end
    redirect_to :back
   end
end
