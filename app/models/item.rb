class Item < ActiveRecord::Base
  validates :name, :presence => true
  validates :description, :presence => true
  validates :category_id, :presence => true

  has_many :favorites, :dependent => :destroy
  has_many :fans, :through => :favorites, :source => :person

  has_many :events, :foreign_key => "subject_id" 
  has_many :groups, :foreign_key => "item_id"

  belongs_to :category
  attr_accessor :selected

  def initialize
    super
    self.selected = false
  end

  def image_url(size = :thumb_large)
    result = if size == :thumb_medium && self[:image_url_medium]
       self[:image_url_medium]
     elsif size == :thumb_small && self[:image_url_small]
       self[:image_url_small]
     else
       self[:image_url_large]
     end
    (result != nil && result.length > 0) ? result : default_url(size)
  end

  def self.all_items(categories, myitems, city, user)
    items = Item.all
    items_ids = items.map{|i| i.id}

    fans_counts = {  }
    events_counts = {  }  

    Event.week.joins(:location).select("subject_id, count(*) evesize")
      .where(:subject_id => items_ids, :locations => {:city_id => city.id}).group(:subject_id).each do |count|
      events_counts[count.subject_id] = count.evesize
    end

    if user
      user.person.interests.order("rand()").limit(5).each do |myitem| 
          myitems.push({:item => myitem, :count=>events_counts[myitem.id]?events_counts[myitem.id]:0})
      end
    end

    Favorite.select("item_id, count(*) fansize")
      .where(:item_id => items_ids).group(:item_id).each do |count|
      fans_counts[count.item_id] = count.fansize
    end

    items_hash = {  }

    categories.each do |category|
      items_hash[category.id] = [  ]  
    end

    items.each do |item|
      items_hash[item.category_id].push({:item => item, 
                                          :events_count => events_counts[item.id]?events_counts[item.id]:0, 
                                          :fans_count => fans_counts[item.id]?fans_counts[item.id]:0})
    end

    categories.each do |category|
      items_hash[category.id].sort!{ |x, y| y[:fans_count] <=> x[:fans_count] }
    end

    return items_hash
  end

  def self.hot_items(size, city)
    items = [  ]

    if city == nil
      items = self.joins(:events).where(:events => {:start_at => (Time.now.beginning_of_week)..(Time.now.end_of_week)})
        .group(:subject_id).order("count(subject_id) DESC").limit(size)

      if items.length < size
        items = self.joins(:events).where(:events => {:start_at => (Time.now.beginning_of_month)..(Time.now.end_of_month)})
          .group(:subject_id).order("count(subject_id) DESC").limit(size)
      end
    else
      items = self.joins(:events, :events => :location)
        .where(:events => {:start_at => (Time.now.beginning_of_week)..(Time.now.end_of_week),
                           :locations => {:city_id => city.id}})
        .group(:subject_id).order("count(subject_id) DESC").limit(size)

      if items.length < size
        items = self.joins(:events, :events => :location)
         .where(:events => {:start_at => (Time.now.beginning_of_month)..(Time.now.end_of_month), 
                            :locations => {:city_id => city.id}})
         .group(:subject_id).order("count(subject_id) DESC").limit(size)
      end
    end
    
    return items
  end

  def self.get_user_items(user)
    items_array = []

    if user == nil
       return items_array
    end

    items = user.person.interests 
    items_ids = items.map{|i| i.id}

    fans_counts = {  }
    events_counts = {  }
    groups_counts = {  }  

    Favorite.select("item_id, count(*) fansize")
      .where(:item_id => items_ids).group(:item_id).each do |count|
      fans_counts[count.item_id] = count.fansize
    end

    city = City.find_by_pinyin(user.city.pinyin)

    Event.week.joins(:location).select("subject_id, count(*) evesize")
      .where(:subject_id => items_ids, :locations => {:city_id => city.id}).group(:subject_id).each do |count|
      events_counts[count.subject_id] = count.evesize
    end

    Group.select("item_id, count(*) gpcount").where(:item_id => items_ids, :city_id => city.id)
      .group(:item_id).each do |count|
      groups_counts[count.item.id] = count.gpcount
    end

    items.each do |item|
      items_array.push({:item => item, 
                        :fans_count=>fans_counts[item.id]?fans_counts[item.id]:0,
                        :events_count=>events_counts[item.id]?events_counts[item.id]:0,
                        :groups_count=>groups_counts[item.id]?groups_counts[item.id]:0})
    end
    
    return items_array
  end

  def self.add_fan(item_id, user)
    favorite = Favorite.new(:item_id => item_id, :person_id => user.person.id)
    favorite.save
  end

  def self.remove_fan(item_id, user)
    Favorite.destroy_all(:item_id => item_id, :person_id => user.person.id)
  end

  def random_people(city, limit_num, except)
    fans.at_city(city.id).order('rand()').limit(limit_num) - [except]
  end

  def active_fans(city, limited)
    time_scope = (Time.now.beginning_of_week)..(Time.now.end_of_week)
    people = Person.joins(:involved_events, :interests, :profile => :location)
          .where(:events => {:subject_id => self.id, :start_at => time_scope},
                 :items => {:id => self.id}, :involvements => {:is_pending => false}, :locations =>{:city_id => city.id})
          .group("involvements.person_id").order("count(event_id) DESC").limit(limited).includes(:profile)

    if people.length < limited
      time_scope = (Time.now.beginning_of_month)..(Time.now.end_of_month)
      people = Person.joins(:involved_events, :interests, :profile => :location)
                     .where(:events => {:subject_id => self.id, :start_at => time_scope},
                            :items => {:id => self.id}, :involvements => {:is_pending => false}, :locations => {:city_id => city.id})
                     .group("involvements.person_id").order("count(event_id) DESC").limit(limited).includes(:profile)
    end

    if people.length < limited
      peopleplus = self.fans.joins(:profile => :location)
                  .find(:all, :limit => (limited - people.length),
                        :conditions => ['people.id not in (?) AND locations.city_id = ?', people.map(&:id), city.id],
                        :order => 'rand()')
                       
      if peopleplus
        people += peopleplus 
      end
    end
    return people
  end

  def hot_stars(limited)
    Person.joins(:involved_events, :interests)
          .where(:events => {:subject_id => self.id}, :items => {:id => self.id}, 
                 :involvements => {:is_pending => false})
          .group("involvements.person_id").order("count(event_id) DESC").limit(limited).includes(:profile)
  end

  def hot_groups(limited, city)
    groups = Group.joins(:members).where(:item_id => self.id, :city_id => city.id)
          .group(:group_id).order("count(group_id) DESC").limit(limited)

    group_ids = groups.map{|i| i.id}

    group_members_counts = { }
    group_topics_counts = { }
    group_events_counts = { }

    Membership.select("group_id, count(*) membersize").where(:group_id => group_ids, :pending => false)
      .group(:group_id).each do |count|
        group_members_counts[count.group_id] = count.membersize
    end


    Event.select("group_id, count(*) eventsize").where(:group_id => group_ids)
      .group(:group_id).each do |count|
        group_events_counts[count.group_id] = count.evesize
    end

    Topic.joins(:forum).select("forums.discussable_id group_id, count(*) topicsize")
      .where(:forums => {:discussable_id => group_ids, :discussable_type => "Group"}).group(:forum_id).each do |count|
        group_topics_counts[count.group_id] = count.topicsize
    end

    groups_hash = []
    groups.each do |group|
      groups_hash.push({:group => group,
                        :membersize => group_members_counts[group.id]?group_members_counts[group.id]:0,
                        :eventsize => group_events_counts[group.id]?group_events_counts[group.id]:0,
                        :topicsize => group_topics_counts[group.id]?group_topics_counts[group.id]:0})      
    end
    return groups_hash 
  end

  private

  def default_url(size)
     case size
        when :thumb_medium then "/images/event/event_medium.jpg"
        when :thumb_large   then "/images/event/event_large.jpg"
        when :thumb_small   then "/images/event/event_small.jpg"
     end
  end

end

