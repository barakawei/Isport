#For Guidance
#http://github.com/thoughtbot/factory_girl
# http://railscasts.com/episodes/158-factories-not-fixtures

def r_str
  ActiveSupport::SecureRandom.hex(3)
end

Factory.define :profile do |p|
  p.sequence(:first_name) { |n| "Robert#{n}#{r_str}" }
  p.sequence(:last_name)  { |n| "Grimm#{n}#{r_str}" }
  p.birthday Date.today
end

Factory.define :person do |p|
  p.sequence(:diaspora_handle) { |n| "bob-person-#{n}#{r_str}@aol.com" }
  p.sequence(:url)  { |n| AppConfig[:pod_url] }
  p.serialized_public_key OpenSSL::PKey::RSA.generate(1024).public_key.export
  p.after_build do |person|
    person.profile ||= Factory.build(:profile, :person => person)
  end
  p.after_create do |person|
    person.profile.save
  end
end

Factory.define :searchable_person, :parent => :person do |p|
  p.after_build do |person|
    person.profile = Factory.build(:profile, :person => person, :searchable => true)
  end
end

Factory.define :like do |x|
  x.association :author, :factory => :person
  x.association :target, :factory => :status_message
end

Factory.define :user do |u|
  u.getting_started false
  u.sequence(:username) { |n| "bob#{n}#{r_str}" }
  u.sequence(:email) { |n| "bob#{n}#{r_str}@pivotallabs.com" }
  u.password "bluepin7"
  u.password_confirmation { |u| u.password }
  u.serialized_private_key  OpenSSL::PKey::RSA.generate(1024).export
  u.after_build do |user|
    user.person = Factory.build(:person, :profile => Factory.build(:profile),
                                :owner_id => user.id,
                                :serialized_public_key => user.encryption_key.public_key.export,
                                :diaspora_handle => "#{user.username}@#{AppConfig[:pod_url].gsub(/(https?:|www\.)\/\//, '').chop!}")
  end
  u.after_create do |user|
    user.person.save
    user.person.profile.save
  end
end

Factory.define :user_with_aspect, :parent => :user do |u|
  u.after_create { |user| Factory(:aspect, :user => user) }
end

Factory.define :aspect do |aspect|
  aspect.name "generic"
  aspect.association :user
end

Factory.define(:status_message) do |m|
  m.sequence(:text) { |n| "jimmy's #{n} whales" }
  m.association :author, :factory => :person
  m.after_build do|m|
    m.diaspora_handle = m.author.diaspora_handle
  end
end

Factory.define(:status_message_with_photo, :parent => :status_message) do |m|
  m.sequence(:text) { |n| "There are #{n} ninjas in this photo." }
  m.after_build do |m|
    p = Factory(:photo, :author => m.author, :status_message => m, :pending => false, :public => m.public)
  end
end

Factory.define(:photo) do |p|
  p.sequence(:random_string) {|n| ActiveSupport::SecureRandom.hex(10) }
  p.after_build do |p|
    p.unprocessed_image.store! File.open(File.join(File.dirname(__FILE__), 'fixtures', 'button.png'))
    p.process
    p.update_remote_path
  end
end

Factory.define :reshare do |r|
  r.association(:root, :public => true, :factory => :status_message)
  r.association(:author, :factory => :person)
end

Factory.define :service do |service|
  service.nickname "sirrobertking"
  service.type "Services::Twitter"

  service.sequence(:uid)           { |token| "00000#{token}" }
  service.sequence(:access_token)  { |token| "12345#{token}" }
  service.sequence(:access_secret) { |token| "98765#{token}" }
end

Factory.define :service_user do |s_user|
  s_user.sequence(:uid) { |id| "a#{id}"}
  s_user.sequence(:name) { |num| "Rob Fergus the #{num.ordinalize}" }
  s_user.association :service
  s_user.photo_url "/images/user/adams.jpg"
end

Factory.define(:comment) do |comment|
  comment.sequence(:text) {|n| "#{n} cats"}
  comment.association(:author, :factory => :person)
  comment.association(:post, :factory => :status_message)
end

Factory.define(:notification) do |n|
  n.association :recipient, :factory => :user
  n.association :target, :factory => :comment
  n.type 'Notifications::AlsoCommented'

  n.after_build do |note|
    note.actors << Factory.build( :person )
  end
end

