module EventsHelper
  def is_reference_of(event)
    unless current_user
      false
    else
      event.references.include?(current_user.person)
    end 
  end

  def is_participant_of(event)
    unless current_user 
      false
    else
      event.participants.include?(current_user.person)
    end
  end

  
  def trim_info(info, size)
    if info.size > size 
      info = info[0, size] + "..."
    end
    info
  end

  def remove_type(type)
    I18n.t("events.remove_type.#{type}")  
  end
  
  def get_link_by_type(type, event)
    case type
    when "joined"
      link_to t('events.save'), url_for(:action => "remove_participant", 
                                        :id => event.id), :class => "button" 
    when "recommended"
      link_to t('events.save'), url_for(:controller => "event_recommendations", 
                                        :action => "remove_reference", :id => event.id), :class => "button" 
    end 
  end

  def event_application_link(event)
    unless is_participant_of(event) 
      if event.ongoing?
        "<h4 class=\"top\">#{I18n.t('events.ongoing.application_stopped')}</h4>".html_safe 
      elsif event.over?
        "<h4 class=\"top\">#{I18n.t('events.over.application_stopped')}</h4>".html_safe 
      elsif event.participants_full? 
        "<h4 class=\"top\">#{I18n.t('events.participants_full')}</h4>".html_safe  
      else
        "<p>#{link_to t('events.apply'), involvements_path(:id => event.id), 
                                         :method => "post", :class => "button"
  }</p>".html_safe  
      end
    else
      ("<h4 class=\"top\">#{I18n.t('events.involved')}</h4>" +
      "<p>#{link_to t('events.cancel_apply'), 
            involvement_path(:id => event.id), :method => "delete", :class => "button"}</p>").html_safe
    end
  end
  def event_status(event)
    status = if event.ongoing?  
              I18n.t('events.status.ongoing')
             elsif event.over?  
              I18n.t('events.status.over')
             else 
              I18n.t('events.status.not_started'); 
             end
  end

  def invite_link(friends, invitees, friend_participants)
    return if friends.size <= 0 || friends.size <= invitees.size + friend_participants.size
    name = (invitees.size == 0 && friend_participants.size == 0 ) ? I18n.t("events.invite_friends") : I18n.t("events.invite_more_friends")
    link_to name, "#", :class => "friend_select_input" 
  end

end
