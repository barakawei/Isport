module GroupsHelper
  def is_active?(current, page_name)
    "active" if current == page_name 
  end

  def invite_link(friends, invitees, friend_members)
    return if friends.size <= 0 || friends.size <= invitees.size + friend_members.size
    name = (invitees.size == 0 && friend_members.size == 0 ) ? I18n.t("events.invite_friends") : I18n.t("events.invite_more_friends")
    link_to name, "#", :class => "friend_select_input" 
  end
end
