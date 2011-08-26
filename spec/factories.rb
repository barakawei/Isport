#For Guidance
#http://github.com/thoughtbot/factory_girl
# http://railscasts.com/episodes/158-factories-not-fixtures

def r_str
  ActiveSupport::SecureRandom.hex(3)
end


Factory.define :contact do |c|
  c.receiving false
  c.sharing false
  c.association :user
  c.association :person
end

Factory.define :profile do |p|
  p.sequence(:name) { |n| "messi#{n}#{r_str}" }
  p.birthday Date.today
  p.gender 1
end

Factory.define :person do |p|
  p.after_build do |person|
    person.profile ||= Factory.build(:profile, :person => person)
  end
  p.after_create do |person|
    person.profile.save
  end
end

Factory.define :user do |u|
  u.getting_started false
  u.sequence(:email) { |n| "sun#{n}#{r_str}@alyosha.com" }
  u.password "123456"
  u.password_confirmation { |u| u.password }
  u.after_build do |user|
    user.person = Factory.build(:person, :profile => Factory.build(:profile,:name => 'sun'),
                                :user_id => user.id)
  end
  u.after_create do |user|
    user.person.save
    user.person.profile.save
  end
end

Factory.define(:photo) do |p|
  p.sequence(:random_string) {|n| ActiveSupport::SecureRandom.hex(10) }
  p.after_build do |p|
    p.unprocessed_image.store! File.open(File.join(File.dirname(__FILE__), 'fixtures', 'user.png'))
    p.process
    p.update_remote_path
  end
end

Factory.define(:notification) do |n|
  n.association :recipient, :factory => :user
  n.association :target, :factory => :comment
  n.after_build do |note|
    note.actors << Factory.build( :person )
  end
end

