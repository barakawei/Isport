module GroupsHelper
  def is_active?(current, page_name)
    "active" if current == page_name 
  end

  def invite_link(friends, invitees, friend_members)
    return if friends.size <= 0 || friends.size <= invitees.size + friend_members.size
    name = (invitees.size == 0 && friend_members.size == 0 ) ? I18n.t("events.invite_friends") : I18n.t("events.invite_more_friends")
    link_to name, "#", :class => "friend_select_input right" 
  end

  def group_status_info(group,person)
    m = Membership.where(:person_id => person.id, :group_id => group.id)
    return I18n.t('groups.join_mode_des.invited_by_admin')  if m.size > 0 && m[0].pending &&m[0].pending_type == Group::JOIN_BY_INVITATION_FROM_ADMIM 
    case group.join_mode  
      when Group::JOIN_BY_INVITATION_FROM_ADMIM 
        I18n.t("groups.join_mode_des.invite_by_admin")
      when Group::JOIN_AFTER_AUTHENTICATAION
        if m.size > 0 && m[0].pending 
          I18n.t('groups.person.status.request_pending')
        end
      else
    end
  end
end
