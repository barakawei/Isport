module ApplicationHelper
  def owner_image_tag(size=nil)
    person_image_tag(current_user.person, size)
  end

  def person_image_tag(person, size=:thumb_small)
    "<img alt=\"#{h(person.name)}\" class=\"avatar\" data-person_id=\"#{person.id}\" src=\"#{person.profile.image_url(size)}\" title=\"#{h(person.name)}\">".html_safe
  end

  def event_image_tag(size=nil)
    "<img alt=\"#{h(event.title)}\" class=\"avatar\"  src=\"#{event.image_url(size)\" >".html_safe
  end

end
