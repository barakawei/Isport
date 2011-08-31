class EventRecommendationsController < ApplicationController
  before_filter :registrations_closed?
  before_filter :get_event
  respond_to :js

  def add_reference
    @event.references << current_user.person
    @event.dispatch_event(:recommendation,current_user)
    respond_with @event
  end

  def remove_reference
    @event.references.delete(current_user.person)    
    respond_with @event
  end

  private
  
  def get_event
    @event = Event.find(params[:id])
  end
end
