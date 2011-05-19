module EventsHelper
  def is_participant_of(event)
     event.participants.include?(current_user.person) ? true : false
  end
end
