module NotificationsHelper
  include ERB::Util
  include ActionView::Helpers::TranslationHelper
  include ActionView
  include ApplicationHelper
  def object_link(note,link = false)
    if !note.target
      return
    end
    if link
      target_type = note.translation_link_key
    else
      target_type = note.translation_key
    end
    if note.actor.instance_of?( Person )
      person = note.actor
    else
      person = note.actor.first
    end
    actor_link = "<a href='#{object_path(person)}'>#{person.name}</a>"
    actors =  note.actor
    if actors.instance_of?( Person )
      actor_text = actors.name
      actors_link = "<a href='#{object_path(person)}'>#{person.name}</a>"
    else
      actor_text = actors.first(3).map{ |a|a.name }.join(t( 'dunhao' ))
      actors_link =  actors.first(3).map{ |a|
        person_link_show_name( a )
      }.join(t( 'dunhao' ))
      size = actors.size
      if size > 3
        actor_text = actor_text + t( 'actors',:size => size)
        actors_link = actors_link + t( 'actors',:size => size)
      end
    end
    if !note.instance_of?(Notifications::StartedSharing)
      if note.instance_of?( Notifications::StatusComment )
        post = note.target
        post_link = "<a href='#{object_path(post)}'>#{t( 'message' )}</a>"
        if link 
          translation(target_type, :actors_link=> actors_link,:post_link => post_link)
        else
          translation(target_type, :actor_text => actor_text)
        end
      elsif note.target_type == 'Group'
        group = note.target
        group_link =  "<a href='#{object_path(group)}'>#{group.name}</a>"
        translation(target_type, :actor_link => actor_link,:group_link => group_link)
      elsif note.target_type == 'Event'
        event= note.target
        event_link =  "<a href='#{object_path(event)}'>#{event.title}</a>"
        translation(target_type, :actor_link => actor_link,:event_link => event_link)
      elsif note.target_type == 'TopicComment'
        topic = note.target.commentable.commentable
        group = topic.forum.discussable
        group_link =  "<a href='#{object_path(group)}'>#{group.name}</a>"
        comment_link =  "<a href='#{group_topic_path(group,topic)}'>#{t( 'comment' )}</a>"
        translation(target_type, :actor_link => actor_link,:comment_link => comment_link,:group_link =>group_link )
      elsif note.target_type == 'EventComment'
        event = note.target.commentable.commentable
        comment =  note.target.commentable
        event_link =  "<a href='#{object_path(event)}'>#{event.title}</a>"
        comment_link =  "<a href='#{object_path(event)}'>#{t( 'comment' )}</a>"
        translation(target_type, :actor_link => actor_link,:comment_link => comment_link,:event_link =>event_link )
      elsif note.instance_of?( Notifications::Mention )
        post = note.target
        post_link = "<a href='#{object_path(post)}'>#{t( 'message' )}</a>"
        if link 
          translation(target_type, :actors_link=> actors_link,:post_link => post_link)
        else
          translation(target_type, :actor_text => actor_text)
        end
      elsif note.instance_of?( Notifications::PicComment ) 
        pic = note.target
        pic_link = "<a href='#{object_path(pic)}'>#{t( 'pictures' )}</a>"
        if link 
          translation(target_type, :actors_link=> actors_link,:pic_link => pic_link)
        else
          translation(target_type, :actor_text => actor_text)
        end
      end
    else 
      if link 
        translation(target_type, :actors_link => actors_link)
      else
        translation(target_type, :actor_text => actor_text)
      end
    end
    
  end

  def translation(target_type, opts = {})
    t("#{target_type}", opts).html_safe
  end

  def notification_message_for(note)
    object_link(note)
  end

  def notification_image_link( note ,size = :thumb_small)
    object_image_link( note.target,size )   
  end

  def notification_time_ago( note )
    target = note.target
    if note.instance_of?( Notifications::InvolvementEvent ) || note.instance_of?( Notifications::InviteEvent )  
      target = Involvement.where( :event_id => target.id,:person_id => note.actor.id).first
    elsif note.instance_of? ( Notifications::RecommendationEvent )
      target = EventRecommendation.where( :item_id => target.id,:person_id => note.actor.id).first
    end
    how_long_ago( target )
  end
  
end

