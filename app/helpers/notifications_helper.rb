module NotificationsHelper
  include ERB::Util
  include ActionView::Helpers::TranslationHelper
  include ActionView
  include ApplicationHelper
  def object_link(note)
    target_type = note.translation_key
    actor = note.actor
    actor_link = "<a href='#{object_path(actor)}'>#{actor.name}</a>"
    if !note.instance_of?(Notifications::StartedSharing)
      if note.instance_of?( Notifications::StatusComment )
        post = note.target.post
        post_link = "<a href='#{object_path(post)}'>#{t( 'message' )}</a>"
        translation(target_type, :actor_link => actor_link,:post_link => post_link)
      elsif note.target_type == 'Group'
        group = note.target
        group_link =  "<a href='#{object_path(group)}'>#{group.name}</a>"
        translation(target_type, :actor_link => actor_link,:group_link => group_link)
      elsif note.target_type == 'Event'
        event= note.target
        event_link =  "<a href='#{object_path(event)}'>#{event.title}</a>"
        translation(target_type, :actor_link => actor_link,:event_link => event_link)
      elsif note.target_type == 'TopicComment'
        topic_comment = note.target.commentable
        comment_link =  "<a href='#{object_path(topic_comment)}'>#{t( 'message' )}</a>"
        translation(target_type, :actor_link => actor_link,:comment_link => comment_link
      end
    else 
      translation(target_type, :actor_link => actor_link)
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

