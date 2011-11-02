#init event album
Event.all.each do |e|
  Album.find_or_create_by_imageable_id_and_name(:imageable_id => e.id,:name =>'default',:imageable_type => 'Event')
end

#init person album
Person.all.each do |p|
  Album.find_or_create_by_imageable_id_and_name(:imageable_id =>p.id,:name => 'status_message',:imageable_type =>'Person')
  album = Album.find_or_create_by_imageable_id_and_name(:imageable_id =>p.id,:name => 'avatar',:imageable_type =>'Person')
  pic = Pic.new
  pic.remote_photo_path = "/uploads/images/"
  pic.author = p
  pic.image_width = 200
  pic.image_height = 200
  url = p.profile.image_url
  if url.index("/user/").nil? && album.pics.size == 0
    length = "/uploads/images/thumb_large_".length
    pic.remote_photo_name = url[ length,url.length ] 
    pic.random_string = url[ length,url.length].split( "." )[ 0 ]
    pic.save
    Pic.connection.execute("update pics set avatar_processed_image='#{url[ length,url.length ]}', unprocessed_image='#{url[ length,url.length ]}' where id=#{pic.id}")
    album.pics << pic
  end
end

#delete invalid notifactions
Notification.all.each do |n|
  if n.target.nil?
    n.destroy
  end
end

# update item_id if post has item_topic_id
Post.joins( :item_topic ).each do |p|
  item_id = p.item_topic.item.id
  Pic.connection.execute("update posts set item_id='#{item_id}' where id=#{p.id}")
end

#update everyone follow admin
User.where( :admin => false,:getting_started => false ).each do |u|
  User.where( :admin=> true ).each do |admin|
    contact_user = u.contacts.find_or_initialize_by_person_id(admin.person.id)
    unless contact_user.receiving?
      contact_user.receiving = true
    end
    contact_user.save
    contact = admin.contacts.find_or_initialize_by_person_id(u.person.id)
    unless contact.sharing?
      contact.sharing= true
    end
    contact.save 
  end
end
