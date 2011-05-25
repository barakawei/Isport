module EventsHelper
  def is_participant_of(event)
    unless current_user 
      false
    else
      event.participants.include?(current_user.person) ? true : false
    end
  end

  def error_on(event, field)
    if @event.errors[field].any?
      %(<span class='validation-error'>
        #{I18n.t("activerecord.attributes.event."+field.to_s)}#{@event.errors[field].flatten[0]}</span>).html_safe
    end
  end
end
