#init event album
#Event.all.each do |e|
#  Album.find_or_create_by_imageable_id_and_name(:imageable_id => e.id,:name =>'default',:imageable_type => 'Event')
#end
#
##init person album
#Person.all.each do |p|
#  Album.find_or_create_by_imageable_id_and_name(:imageable_id =>p.id,:name => 'status_message',:imageable_type =>'Person')
#  album = Album.find_or_create_by_imageable_id_and_name(:imageable_id =>p.id,:name => 'avatar',:imageable_type =>'Person')
#  pic = Pic.new
#  pic.remote_photo_path = "/uploads/images/"
#  pic.author = p
#  pic.image_width = 200
#  pic.image_height = 200
#  url = p.profile.image_url
#  if url.index("/user/").nil? && album.pics.size == 0
#    length = "/uploads/images/thumb_large_".length
#    pic.remote_photo_name = url[ length,url.length ] 
#    pic.random_string = url[ length,url.length].split( "." )[ 0 ]
#    pic.save
#    Pic.connection.execute("update pics set avatar_processed_image='#{url[ length,url.length ]}', unprocessed_image='#{url[ length,url.length ]}' where id=#{pic.id}")
#    album.pics << pic
#  end
#end
#
##delete invalid notifactions
#Notification.all.each do |n|
#  if n.target.nil?
#    n.destroy
#  end
#end
#
## update item_id if post has item_topic_id
#Post.joins( :item_topic ).each do |p|
#  item_id = p.item_topic.item.id
#  Pic.connection.execute("update posts set item_id='#{item_id}' where id=#{p.id}")
#end
#
##update everyone follow admin
#User.where( :admin => false,:getting_started => false ).each do |u|
#  User.where( :admin=> true ).each do |admin|
#    contact_user = u.contacts.find_or_initialize_by_person_id(admin.person.id)
#    unless contact_user.receiving?
#      contact_user.receiving = true
#    end
#    contact_user.save
#    contact = admin.contacts.find_or_initialize_by_person_id(u.person.id)
#    unless contact.sharing?
#      contact.sharing= true
#    end
#    contact.save 
#  end
#end
#
#update notifications
  users = User.where(:getting_started => false).each do |u|
    #update StartedSharing note
    notes = Notification.where(:recipient_id => u.id,:type => "Notifications::StartedSharing")
    note_ids = notes.map{ |n|n.id }.join( "," )
    na = NotificationActor.where( :notification_id => notes )
    na_ids = na.map{ |n|n.id }.join( "," )
    actors = na.map{ |n| n.person}
    new_note = Notifications::StartedSharing.new(:target => u.person,:recipient_id => u.id)
    new_note.actor << actors
    new_note.unread = 0
    new_note.save!
    if notes.size > 0
      Notification.connection.execute("delete from notifications where id in (#{note_ids})")
    end
    if na.size > 0
      NotificationActor.connection.execute("delete from notification_actors where id in (#{na_ids})")
    end
    #update StatusComment note
    note_sc = Notification.where(:recipient_id => u.id,:type => "Notifications::StatusComment",:target_type => "Comment")
    note_sc_ids = note_sc.map{ |n|n.id }.join( "," )
    na_sc_all = NotificationActor.where( :notification_id => note_sc )
    na_sc_ids_all = na_sc_all.map{ |n|n.id }.join( "," )
    note_sc.each do |n|
      comment =  n.target
      if comment
        post = comment.post
      end
      if post
        na_sc = NotificationActor.where( :notification_id => n)
        actors_sc = na_sc.map{ |n| n.person}
        has_note_sc = Notifications::StatusComment.where(:target_id => post,:recipient_id => u.id,:target_type => "Post").first
        if has_note_sc.nil?
          new_note_sc = Notifications::StatusComment.new(:target => post,:recipient_id => u.id) 
          new_note_sc.actor << actors_sc
          new_note_sc.unread = 0
          new_note_sc.save!
        else
          has_na_sc = NotificationActor.where( :notification_id => has_note_sc,:person_id => actors_sc ).first
          if has_na_sc.nil?
            has_note_sc.actor << actors_sc
            has_note_sc.save!
          end
        end
      end
    end
    if note_sc.size > 0
      Notification.connection.execute("delete from notifications where id in (#{note_sc_ids})")
    end
    if na_sc_all.size > 0
      NotificationActor.connection.execute("delete from notification_actors where id in (#{na_sc_ids_all})")
    end
    #update mention note
    note_m = Notification.where(:recipient_id => u.id,:type => "Notifications::Mention",:target_type => "Mention")
    note_m_ids = note_m.map{ |n|n.id }.join( "," )
    na_m_all = NotificationActor.where( :notification_id => note_m )
    na_m_ids_all = na_m_all.map{ |n|n.id }.join( "," )
    note_m.each do |n|
      target = n.target
      if target.instance_of?( Post )
        post = target
      else
        if target
          post = target.post
        end
      end
      if post
        na_m = NotificationActor.where( :notification_id => n)
        actors_m = na_m.map{ |n| n.person}
        has_note_m = Notifications::Mention.where(:target_id => post,:recipient_id => u.id,:target_type => "Post").first
        if has_note_m.nil?
          new_note_m = Notifications::Mention.new(:target => post,:recipient_id => u.id) 
          new_note_m.actor << actors_m
          new_note_m.unread = 0
          new_note_m.save!
        else
          has_na_m = NotificationActor.where( :notification_id => has_note_m,:person_id => actors_m ).first
          if has_na_m.nil?
            has_note_m.actor << actors_m
            has_note_m.save!
          end
        end
      end
    end
    if note_m.size > 0
      Notification.connection.execute("delete from notifications where id in (#{note_m_ids})")
    end
    if na_m_all.size > 0
      NotificationActor.connection.execute("delete from notification_actors where id in (#{na_m_ids_all})")
    end
    #update picComment note
    note_p = Notification.where(:recipient_id => u.id,:type => "Notifications::PicComment",:target_type => "PicComment")
    note_p_ids = note_p.map{ |n|n.id }.join( "," )
    na_p_all = NotificationActor.where( :notification_id => note_p )
    na_p_ids_all = na_p_all.map{ |n|n.id }.join( "," )
    note_p.each do |n|
      target = n.target
      if target
        pic = target.pic
      end
      if pic
        na_p = NotificationActor.where( :notification_id => n)
        actors_p = na_p.map{ |n| n.person}
        has_note_p = Notifications::PicComment.where(:target_id => pic,:recipient_id => u.id,:target_type => "Pic").first
        if has_note_p.nil?
          new_note_p = Notifications::PicComment.new(:target => pic,:recipient_id => u.id) 
          new_note_p.actor << actors_p
          new_note_p.unread = 0
          new_note_p.save!
        else
          has_na_p = NotificationActor.where( :notification_id => has_note_p,:person_id => actors_p ).first
          if has_na_p.nil?
            has_note_p.actor << actors_p
            has_note_p.save!
          end
        end
      end
    end
    if note_p.size > 0
      Notification.connection.execute("delete from notifications where id in (#{note_p_ids})")
    end
    if na_p_all.size > 0
      NotificationActor.connection.execute("delete from notification_actors where id in (#{na_p_ids_all})")
    end
    #delete all EventComment,invite_event,InviteGroup,InvolvementEvent,topc notes
    Notification.connection.execute("delete from notifications where type = 'Notifications::InviteEvent'")
    Notification.connection.execute("delete from notifications where type = 'Notifications::InviteGroup'")
    Notification.connection.execute("delete from notifications where type = 'Notifications::InvolvementEvent'")
    Notification.connection.execute("delete from notifications where type = 'Notifications::EventComment'")
    Notification.connection.execute("delete from notifications where type = 'Notifications::TopicComment'")
  end

