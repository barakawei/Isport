module ApplicationHelper
  def next_page_path
    if controller.instance_of?(PeopleController)
      person_path(@person, :max_time => @posts.last.created_at.to_i)
    end
  end


  def how_long_ago(obj)
    timeago(obj.created_at)
  end

  def object_path( object )
    return "" if object.nil?
    object = object.person if object.instance_of? User
    eval("#{object.class.name.underscore}_path(object)")
  end

  def object_image_link(object,size=:thumb_small)
    return "" if object.nil?
    object = object.person if object.instance_of? User
    eval ("#{object.class.name.underscore}_image_link(object,size)")
  end

  def timeago(time, options={})
    options[:class] ||= "timeago"
    content_tag(:abbr, time.to_s, options.merge(:title => time.iso8601)) if time
  end
  
  def owner_image_tag(size=nil)
    person_image_tag(current_user.person, size)
  end

  def person_image_tag(person, size=:thumb_small)
    "<img  class=\"avatar\" data_person_id=\"#{person.id}\" src=\"#{person.profile.image_url(size)}\">".html_safe
  end

  def owner_image_link
    person_image_link(current_user.person)
  end

  def person_image_link(person, size=:thumb_small)
    return "" if person.nil? || person.profile.nil?
    link_to person_image_tag(person, size),person_path( person )
  end


  def event_image_link(event, size)
    link_to event_image_tag(event, size), event_path(event)
  end

  def item_image_link(item, opts={})
    return "" if item.nil?
    if opts[:to] == :photos
      link_to item_image_tag(item, opts[:size]), item_photos_path(item)
    else
      "<a href='/items/#{item.id}'>
  #{item_image_tag(item, opts[:size])}
</a>".html_safe
    end
  end

  def person_link(person, opts={})
    "<a href='/people/#{person.id}' class='#{opts[:class]}'>
  #{h(person.name)}
</a>".html_safe
  end

  def event_image_tag(event,size)
    "<img title=\"#{h(event.title)}\" class=\"avatar\"  src=\"#{event.image_url(size)}\" >".html_safe
  end

  def item_image_tag(item,size)
    "<img title=\"#{h(item.name)}\" class=\"avatar\"  src=\"#{item.image_url(size)}\" >".html_safe
  end

  def pagination_options(param_name, param)
    {:previous_label => t("pagination.previous"), 
     :next_label => t("pagination.next"),
     :param_name => (param_name == nil) ? :page : param_name,
     :params => param} 
  end
end
