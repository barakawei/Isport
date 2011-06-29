class EventRecommendationsController < ApplicationController
  before_filter :get_event

  def add_reference
    @event.references << current_user.person
    redirect_to(event_path(@event))
  end

  def remove_reference
    @event.references.delete(current_user.person)    
    redirect_to :back
  end

  private
  
  def get_event
    @event = Event.find(params[:id])
  end
end
