module ApplicationHelper
  def follow_button_tag( person )
    link_html = "<div class='follow_button'></div>"
    contact = current_user.contact_for( person )
    if person.id == current_user.person.id
    elsif contact.nil? || !contact.receiving
      button_html = "<div class='follow glass_button' data_id='#{person.id}'><span>"+t('follow')+"</span></div>"
      link_html = link_to({:controller => 'contacts', :action => 'create',:person_id => person.id},:method =>'post',:remote => true) do
        button_html.html_safe
      end
    elsif contact.receiving
      button_html = "<div class='following glass_button' data_id='#{person.id}'><span>"+t('following')+"</span></div>"
      link_html = link_to({:controller => 'contacts', :action => 'destroy',:person_id => person.id},:method =>'delete',:remote => true) do
        button_html.html_safe
      end
    end
    link_html.html_safe
  end

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

  def object_name_link( object,opts={  } )
    return "" if object.nil?
    if !opts[:length].nil?
      name = truncate(object.name,:length => opts[:length])
    else
      name = object.name
    end
    link_to name,object_path( object )
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
    if size == :thumb_small
      avatar_html = "<img  class=\"avatar person_avatar_detail radius_small\" data_person_id=\"#{person.id}\" src=\"#{person.profile.image_url(size)}\">"
    elsif size == :thumb_medium
      avatar_html = "<img  class=\"avatar person_avatar_detail radius_medium\" data_person_id=\"#{person.id}\" src=\"#{person.profile.image_url(size)}\">"
    elsif size == :thumb_large
      avatar_html = "<img  class=\"avatar person_avatar_detail radius_large\" data_person_id=\"#{person.id}\" src=\"#{person.profile.image_url(size)}\">"
    end

    avatar_html.html_safe
  end
  

  def owner_image_link
    person_image_link(current_user.person)
  end

  def person_image_link(person, size=:thumb_small)
    return "" if person.nil?
    link = link_to person_image_tag(person, size),person_path( person )
    "<div class='avatar_container'>#{link}</div>".html_safe
  end

  def person_image_link2(person, size=:thumb_small)
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
    if size == :thumb_small
      "<img title=\"#{h(event.title)}\" class=\"avatar radius_small\"  src=\"#{event.image_url(size)}\" >".html_safe
    elsif size == :thumb_medium
      "<img title=\"#{h(event.title)}\" class=\"avatar radius_medium\"  src=\"#{event.image_url(size)}\" >".html_safe
    elsif size == :thumb_large
      "<img title=\"#{h(event.title)}\" class=\"avatar radius_large\"  src=\"#{event.image_url(size)}\" >".html_safe
    else
      "<img title=\"#{h(event.title)}\" class=\"avatar radius_little\"  src=\"#{event.image_url(size)}\" >".html_safe
    end
  end

  def group_image_tag(group, size=:thumb_small)
    if size == :thumb_small
      "<img title=\"#{h(group.name)}\" class=\"avatar radius_small\"  src=\"#{group.image_url(size)}\" >".html_safe
    elsif size == :thumb_medium
      "<img title=\"#{h(group.name)}\" class=\"avatar radius_medium\"  src=\"#{group.image_url(size)}\" >".html_safe
    elsif size == :thumb_large
      "<img title=\"#{h(group.name)}\" class=\"avatar radius_large\"  src=\"#{group.image_url(size)}\" >".html_safe
    end
  end

  def group_image_link(group, size=nil)
     link_to group_image_tag(group, size), group_path(group)
  end

  def item_image_tag(item, size=:thumb_small)
    if size == :thumb_small
      "<img title=\"#{h(item.name)}\" class=\"avatar radius_small\"  src=\"#{item.image_url(size)}\" >".html_safe
    elsif size == :thumb_medium
      "<img title=\"#{h(item.name)}\" class=\"avatar radius_medium\"  src=\"#{item.image_url(size)}\" >".html_safe
    elsif size == :thumb_large
      "<img title=\"#{h(item.name)}\" class=\"avatar radius_large\"  src=\"#{item.image_url(size)}\" >".html_safe
    end
  end

  def item_events_notify
    "<img class=\"avatar\"  src=\"/images/items/im_idle_dot.png\" >".html_safe
  end

  def left_arrow
    "<img class=\"avatar\"  src=\"/images/ui/arrow_left.png\" >".html_safe
  end

  def right_arrow
    "<img class=\"avatar\"  src=\"/images/ui/arrow_right.png\" >".html_safe
  end

  def pagination_options(param_name, param)
    {:previous_label => t("pagination.previous"), 
     :next_label => t("pagination.next"),
     :param_name => (param_name == nil) ? :page : param_name,
     :params => param} 
  end

  def error_on(model, field)
    if model.errors[field].any?
      %(<span class='validation-error'>
        *#{I18n.t("activerecord.attributes."+ model.class.to_s.downcase + "."+field.to_s)}#{model.errors[field].flatten[0]}</span>).html_safe
    end
  end
end
