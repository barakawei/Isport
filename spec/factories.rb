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

Factory.define(:group) do |g|
  g.sequence(:name) {|n| "group#{n}#{r_str}"}
  g.sequence(:description) {|n| "this is a group with name group#{n}#{r_str}"}
  g.item_id 1
  g.city_id 1
  g.district_id 1
  g.join_mode 1
end

Factory.define(:item) do |i|
  i.sequence(:name) {|n| "item#{n}#{r_str}"} 
  i.sequence(:description) {|n| "this is a group with name group#{n}#{r_str}"}
  i.category_id 1
end

Factory.define(:city) do |c|
  c.sequence(:name) {|n| "city#{n}#{r_str}"} 
end


Factory.define(:location) do |l|
  l.city_id 1
  l.district_id 1
  l.detail "xinjiekou"
end

Factory.define(:event) do |e|
  e.sequence(:title) {|n| "event#{n}#{r_str}"} 
  e.sequence(:description) {|n| "this is a event with name event#{n}#{r_str}"}
  e.start_at Time.now + 3600
  e.end_at Time.now + 7200
  e.subject_id 1
  e.after_build do |event|
    event.location = Factory.build(:location)
  end

  e.after_create do |event|
    event.location.save
  end
end

