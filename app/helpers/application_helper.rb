module ApplicationHelper
  def how_long_ago(obj)
    timeago(obj.created_at)
  end

  def timeago(time, options={})
    options[:class] ||= "timeago"
    content_tag(:abbr, time.to_s, options.merge(:title => time.iso8601)) if time
  end
  
  def owner_image_tag(size=nil)
    person_image_tag(current_user.person, size)
  end

  def person_image_tag(person, size=:thumb_small)
    "<img alt=\"#{h(person.name)}\" class=\"avatar\" data-person_id=\"#{person.id}\" src=\"#{person.profile.image_url(size)}\" title=\"#{h(person.name)}\">".html_safe
  end

  def owner_image_link
    person_image_link(current_user.person)
  end

  def person_image_link(person, opts = {})
    return "" if person.nil? || person.profile.nil?
    if opts[:to] == :photos
      link_to person_image_tag(person, opts[:size]), person_photos_path(person)
    else
      "<a href='/people/#{person.id}'>
  #{person_image_tag(person)}
</a>".html_safe
    end
  end

  def person_link(person, opts={})
    "<a href='/people/#{person.id}' class='#{opts[:class]}'>
  #{h(person.name)}
</a>".html_safe
  end

  def event_image_tag(event,size=nil)
    puts "start******************"
    puts event.image_url(size)
    puts "end***************"
    "<img  class=\"avatar\"  src=\"#{event.image_url(size)}\" >".html_safe
  end

  
  def pagination_options(param_name, param)
    puts param_name
    {:previous_label => t("pagination.previous"), 
     :next_label => t("pagination.next"),
     :param_name => param_name,
     :params => param} 
  end
end
