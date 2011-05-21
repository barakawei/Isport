module EventsHelper
  def is_participant_of(event)
    unless current_user 
      false
    else
      event.participants.include?(current_user.person) ? true : false
    end
  end
end
