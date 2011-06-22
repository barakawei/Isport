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

  def error_on(event, field)
    if @event.errors[field].any?
      %(<span class='validation-error'>
        *#{I18n.t("activerecord.attributes.event."+field.to_s)}#{@event.errors[field].flatten[0]}</span>).html_safe
    end
  end
  
  def trim_info(info, size)
    if info.size > size 
      info = info[0, size] + "..."
    end
    info
  end

  def filter_path(time_filter_path,item_id, sort_type)
    case time_filter_path
    when "today" 
      events_today_path(item_id, sort_type) 
    when "week" 
      events_week_path(item_id, sort_type) 
    when "weekends" 
      events_weekends_path(item_id, sort_type) 
    when "alltime" 
      events_alltime_path(item_id, sort_type) 
    else
    end  
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
end
