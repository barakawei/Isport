module EventsHelper

  def event_like_button_tag( event )
    if !is_reference_of(event)
      button_html="<div class='join_button glass_button like' event_like_id='#{event.id}'><span>"+t('like')+"</span></div>"
      link_html=link_to({:controller =>"event_recommendations",:action => "add_reference",:id => event.id},:remote => true) do
        button_html.html_safe
      end
    else
      button_html="<div class='join_button glass_button quit like' event_like_id='#{event.id}'><span>"+t('unlike')+"</span></div>"
      link_html=link_to({:controller=>"event_recommendations",:action=>"remove_reference",:id => event.id},:remote => true) do
        button_html.html_safe
      end
    end
  end

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

  def event_status_info(event)
    if event.ongoing?
      "#{I18n.t('events.ongoing.application_stopped')}"
    elsif event.over?
      "#{I18n.t('events.over.application_stopped')}"
    elsif event.participants_full? 
      "#{I18n.t('events.participants_full')}"
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
    link_to name, "#", :class => "friend_select_input right inline" 
  end

  def group_options(person, group)
    options = []
    unless group
      groups = person.joined_groups
      options = groups.collect {|g| [g.name, g.id]}
      options.insert(0, [I18n.t("events.not_group_event_option"), 0])
      options
    else
      options << [group.name, group.id] 
    end
  end

end
