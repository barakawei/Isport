module ApplicationHelper
  def post_content_tag( post )
    if post.respond_to?(:format_message)
      message = post.format_message(post.content)
    end
    if message.nil?
      message
    else
      message.html_safe
    end
  end

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

  def follow_topic_tag( topic )
    followed = topic.followers.include?(current_user.person)
    unless followed
      button_html = "<div class='tfollow glass_button' data_id='#{topic.id}'><span>"+t('follow')+"</span></div>"
      link_html = link_to({:controller => 'item_topics', :action => 'follow', :id => topic.id},:method =>'post',:remote => true) do
        button_html.html_safe
      end
    else 
      button_html = "<div class='detfollow glass_button' data_id='#{topic.id}'><span>"+t('following')+"</span></div>"
      link_html = link_to({:controller => 'item_topics', :action => 'defollow', :id => topic.id},:method =>'delete',:remote => true) do
        button_html.html_safe
      end
    end
    link_html.html_safe
  end

  def followers_count_tag( topic )
    count_html = "<div class='followers_count' data_id='#{topic.id}'>"+t('item_topic.followers_count', :count => topic.followers.size)+"</div>"
    count_html.html_safe
  end

  def element_more_tag(person,action,type=nil)
    button_html = "<div class='element_more'>"+t('all')+"</div>"
    link_html = link_to({:controller => 'people',:action => "#{action}",:type=>"#{type}",:person_id =>person.id}) do
      button_html.html_safe
    end

  end

  def next_page_path
    if controller.instance_of?(PeopleController)
      person_path(@person, :max_time => @posts.last.created_at.to_i)
    end
  end


  def how_long_ago(obj)
    timeago(obj.created_at)
  end

  def how_long_ago_conversation(obj)
    timeago(obj.updated_at)
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
    avatar_html = "<img  class=\"avatar person_avatar_detail \" data_person_id=\"#{person.id}\" src=\"#{person.profile.image_url(size)}\">"
    avatar_html.html_safe
  end

  def person_link_show( person,size=:thumb_small )
    name_html = "<span  class=\"avatar person_avatar_detail \" data_person_id=\"#{person.id}\" src=\"#{person.profile.image_url(size)}\">#{person.name}</span>"
    name_link = "<a href='/people/#{person.id}'>#{name_html}</a>".html_safe
    "<span class='avatar_container'>#{name_link}</span>".html_safe
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
    "<a href='/people/#{person.id}' class='#{opts[:class]}'>#{person.name}</a>".html_safe
  end

  def event_link(event, opts={})
    "<a href='/events/#{event.id}' class='#{opts[:class]}'>#{event.title}</a>".html_safe
  end

  def event_image_tag(event,size)
    "<img title=\"#{h(event.title)}\" class=\"avatar \"  src=\"#{event.image_url(size)}\" >".html_safe
  end

  def item_topic_image_tag(topic, size)
    "<img title=\"#{h(topic.name)}\" class=\"avatar \"  src=\"#{topic.image_url(size)}\" >".html_safe
  end

  def group_image_tag(group, size=:thumb_small)
    "<img title=\"#{h(group.name)}\" class=\"avatar \"  src=\"#{group.image_url(size)}\" >".html_safe
  end

  def group_image_link(group, size=nil)
     link_to group_image_tag(group, size), group_path(group)
  end

  def item_image_tag(item, size=:thumb_small)
    if size == :thumb_large
      "<img title=\"#{h(item.name)}\" class=\"avatar radius_large \"  src=\"#{item.image_url(size)}\" >".html_safe
    else
      "<img title=\"#{h(item.name)}\" class=\"avatar \"  src=\"#{item.image_url(size)}\" >".html_safe
    end
  end

  def item_topic_image_tag(topic, size=:thumb_small)
    "<img title=\"#{h(topic.name)}\" class=\"avatar \"  src=\"#{topic.image_url(size)}\" >".html_safe
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

  def review_status(status)
    case status
      when Event::BEING_REVIEWED then ('<span class="to_be">'+ I18n.t('audit_status.to_be_reviewed_short')+'<span/>').html_safe
      when Event::DENIED then ('<span class="denied">'+ I18n.t('audit_status.denied_short')+'<span/>').html_safe
      when Event::PASSED then ('<span class="passed">'+ I18n.t('audit_status.passed_short')+'<span/>').html_safe
      when Event::CANCELED_BY_EVENT_ADMIN then ('<span class="passed">'+ I18n.t('audit_status.canceled_short')+'<span/>').html_safe
      else ''
    end 
  end

  def long_review_status(status, type)
    case status
      when Event::BEING_REVIEWED then I18n.t('audit_status.to_be_reviewed', :type => type)
      when Event::DENIED then I18n.t('audit_status.not_passed', :type => type)
      when Event::CANCELED_BY_EVENT_ADMIN then I18n.t('audit_status.canceled_by_event_admin', :type => type)
      else ''
    end 
  end
end
