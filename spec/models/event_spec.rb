require 'spec_helper'

describe Event do
  before(:all) do
    @location = Location.create(:city_id => 1, :district_id => 1, :detail => 'zhujianglu')
    @test_event = Event.create(:title => 'Test event model', :description => 'Test event model',
                               :start_at => Time.now.next_week, :end_at => Time.now.next_month,
                               :subject_id => 1, :location=> @location)
    @people = Array.new(10).fill{|i| Person.create(:user_id => (i+20))}
    @test_event.participants += @people[0..8]
    @test_event.invitees << @people[9]
    @test_event.references += @people[1..8]
    @test_event.comments.create(:content => 'ahaha')
    @test_event.reload
  end

  after(:all) do
    @people.each{ |p| p.destroy}
    @test_event.destroy
    @location.destroy
  end

  context 'test counter cache' do
    it 'event participant_count should increated when there is a new member' do
      @test_event.participants_count.should == @test_event.participants.count 
    end

    it 'event participant_count should increated when member pending status become true' do
      m = @test_event.involvements.first
      m.is_pending = true
      m.save
      @test_event.reload
      @test_event.participants_count.should == @test_event.participants.count 
    end

    it 'event participant_count should decreated when members decrase' do
      @test_event.involvements.first.destroy
      @test_event.reload
      @test_event.participants_count.should == @test_event.participants.count 
    end

    it 'event fans_count should increase when there is new fans' do
      @test_event.fans_count.should == @test_event.references.count
    end

    it 'event fans_count should decrease when fans decrease' do
      @test_event.recommendations.destroy_all 
      @test_event.reload
      @test_event.fans_count.should == @test_event.references.count
    end
    
    it 'event comments_count should increase when there is new comment' do
      @test_event.comments_count.should == @test_event.comments.count
    end

    it 'event comments_count should decrease when comments descrese' do
      @test_event.comments.destroy_all
      @test_event.reload
      @test_event.comments_count.should == @test_event.comments.count
    end
  end


  context 'when initialized' do 
    let(:event) { Event.new }
    it "event have a default limit of members 100" do 
      event.participants_limit.should == 100
    end

    it 'event have a default status which is to be audited' do
      event.status.should == 0
    end
  end

  context 'when created with some attributes blank' do
    let(:event) { Event.create}

    it "event should have a title" do
      event.errors[:title][0].should == I18n.t('activerecord.errors.messages.blank')
    end

    it "event shoulde have a start time" do
      event.errors[:start_at][0].should == I18n.t('activerecord.errors.messages.blank')
    end 
    
     it "event should have description" do
      event.errors[:description][0].should == I18n.t('activerecord.errors.messages.blank')
    end 

     it "event should belong to an item" do
      event.errors[:subject_id][0].should == I18n.t('activerecord.errors.messages.blank')
    end 


     it "event should have a location" do
      event.errors[:location][0].should == I18n.t('activerecord.errors.messages.blank')
     end 
  end

  context 'when created with some text attributes over length' do
    let(:event) {Event.create(:title => ("i" * 31), :description => ('i' *2001) )}

    it "event title should less then 300 characters" do 
      event.errors[:title][0].should == I18n.t('activerecord.errors.messages.too_long', :count => 30)
    end
    it "event description should less then 800 characters" do
      event.errors[:description][0].should == I18n.t('activerecord.errors.messages.too_long', :count => 2000)
    end
  end

  context 'when created with not valid participants_limit' do
    let(:event) {Event.new}

    it 'event paritcipants_limit should be integer' do
      event.participants_limit = 'not a number'
      event.save
    end

    it 'event participants_limit should > 0' do
      event.participants_limit = '0'
      event.save
      event.errors[:participants_limit][0].should == I18n.t('activerecord.errors.messages.greater_than', :count => 0)
    end

    it 'event participants_limit should <= 100' do
      event.participants_limit = '101'
      event.save
      event.errors[:participants_limit][0].should == I18n.t('activerecord.errors.messages.less_than_or_equal_to', :count => 100)
    end

    it 'event participants_limit should not less than current participants' do
      @test_event.participants_limit = @test_event.participants.count - 1
      @test_event.save
      @test_event.errors[:participants_limit][0].should == I18n.t('activerecord.errors.event.participants_limit.less_than_current')
    end
  end

  context 'when created with endtime before starttime' do
    let(:event) { Event.new }
    it 'event end time should later than start time' do
      event.start_at = Time.now 
      event.end_at = Time.now.yesterday
      event.save
      event.errors[:end_at][0].should == I18n.t('activerecord.errors.event.end_at.after')
    end
  end

  describe'get event by status scope' do
    before(:all) do
      @location = Location.create(:city_id => 1, :district_id => 1, :detail => 'zhujianglu')
      @status_event = Event.create(:title => 'Test event status', :description => 'Test event model',
                             :start_at => Time.now.next_week, :end_at => Time.now.next_month,
                             :subject_id => 1, :location=> @location)
    end
    context 'when event not start' do
      let(:event) {@status_event.update_attributes(:start_at => Time.now.next_week, :end_at => Time.now.next_month); @status_event}
      it 'not started scope should return event which is not started' do 
        Event.not_started.should include(event)
      end
      it 'on_going scope should not return event which is not started' do 
        Event.on_going.should_not include(event)
      end 
      
      it 'over scope should not return event which is not started' do 
        Event.over.should_not include(event)
      end
    end

    context 'when event is on_going' do
      let(:event) {@status_event.update_attributes(:start_at => Time.now.yesterday, :end_at => Time.now.tomorrow); @status_event}
      it 'not started scope should not return event which is on_going' do 
        Event.not_started.should_not include(event)
      end
      it 'on_going scope should return event which is on_going' do 
        Event.on_going.should include(event)
      end 

      it 'over scope should not return event which is on_going' do 
        Event.over.should_not include(event)
      end
    end

    context 'when event is over' do
      let(:event) {@status_event.update_attributes(:start_at => Time.now.prev_month, :end_at => Time.now.yesterday); @status_event}
      it 'not started scope should not return event which is over' do 
        Event.not_started.should_not include(event)
      end
      it 'on_going scope should not return event which is over' do 
        Event.on_going.should_not include(event)
      end 

      it 'over scope should return event which is over' do 
        Event.over.should include(event)
      end
    end

    after(:all) do
      @status_event.destroy
      @location.destroy
    end
  end

  describe 'test get event by item' do
    before(:all) do
        @location = Location.create(:city_id => 1, :district_id => 1, :detail => 'zhujianglu')
        @item = Item.create(:name => 'football', :description => 'football', :category_id => 1) 
        @item_event= Event.create(:title => 'Test event status', :description => 'Test event model',
                                     :start_at => Time.now.next_week, :end_at => Time.now.next_month,
                                     :subject_id => @item.id, :location=> @location)
    end

    after(:all) do
      @item_event.destroy
      @item.destroy
      @location.destroy
    end

    it 'of_item scope should return event of sepcial item' do
      Event.of_item(@item).should include(@item_event)
    end

    it 'in_items scope should return events in specialed item_ids' do
      Event.in_items([@item.id, 999,1000]).should include(@item_event)
    end
  end

  describe 'get event by time filter' do
     before(:all) do
        @location = Location.create(:city_id => 1, :district_id => 1, :detail => 'zhujianglu')
        @time_event= Event.create(:title => 'Test event status', :description => 'Test event model',
                                     :start_at => Time.now.next_week, :end_at => Time.now.next_month,
                                     :subject_id => 1, :location=> @location)
    end

    after(:all) do
      @time_event.destroy
      @location.destroy
    end
    
    context 'test scope week' do
      it 'when event start time is in this week' do
        @time_event.update_attributes(:start_at => Time.now.beginning_of_week.tomorrow)
        Event.week.should include(@time_event)
      end

      it 'when event start time is not in this week' do
        @time_event.update_attributes(:start_at => Time.now.next_week)
        Event.week.should_not include(@time_event)
      end
    end
    
    context 'test scope month' do
      it 'when event start time is in this month' do
        @time_event.update_attributes(:start_at => Time.now.beginning_of_month.tomorrow)
        Event.month.should include(@time_event)
      end

      it 'when event start time is not in this week' do
        @time_event.update_attributes(:start_at => Time.now.next_month, :end_at => Time.now.next_month.tomorrow)
        Event.month.should_not include(@time_event)
      end
    end

     context 'test scope today' do
      it 'when event start time is at today' do
        @time_event.update_attributes(:start_at => Time.now.beginning_of_day + 60*60)
        Event.today.should include(@time_event)
      end

      it 'when event start time is at today' do
        @time_event.update_attributes(:start_at => Time.now.tomorrow)
        Event.today.should_not include(@time_event)
      end
    end
    
     context 'test scope weekends' do
      it 'when event start time is at weekends' do
        @time_event.update_attributes(:start_at => Time.now.end_of_week - 60*60)
        Event.weekends.should include(@time_event)
      end

      it 'when event start time is at today' do
        @time_event.update_attributes(:start_at => Time.now.end_of_week + 3600)
        Event.weekends.should_not include(@time_event)
      end
    end

    context 'test scope next_week' do
      it 'when event start time is at next_week' do
        @time_event.update_attributes(:start_at => Time.now.next_week + 60*60)
        Event.next_week.should include(@time_event)
      end

      it 'when event start time is not at next_week' do
        @time_event.update_attributes(:start_at => Time.now.next_month, :end_at => Time.now.next_month + 3600)
        Event.next_week.should_not include(@time_event)
      end
    end

    context 'test scope next_month' do
      it 'when event start time is at next_month' do
        @time_event.update_attributes(:start_at => Time.now.next_month+ 60*60)
        Event.next_month.should include(@time_event)
      end

      it 'when event start time is not at next_month' do
        @time_event.update_attributes(:start_at => Time.now.next_month.next_month, :end_at => Time.now.next_month.next_month + 3600)
        Event.next_month.should_not include(@time_event)
      end
    end

    context 'test scope alltime' do
      it 'when event start time is at specialized date' do
        @time_event.update_attributes(:start_at => '2011-08-07 16:53:00', :end_at => '2011-08-07 16:54:00')
        Event.on_date(Time.new(2011,8,7)).should include(@time_event)
      end
      
      it 'when event start time is not at specialized date' do
        @time_event.update_attributes(:start_at => '2011-08-07 16:53:00', :end_at => '2011-08-07 16:54:00')
        Event.on_date(Time.new(2011,8,8)).should_not include(@time_event)
      end
    end

    context 'test scope on_date' do
      it 'when alltime filter is selected' do
        Event.alltime.size.should == Event.all.size
        Event.alltime.should include(@time_event) 
      end
    end
  end

  describe 'get event by location scope' do
    before(:all) do
        @location = Location.create(:city_id => 1, :district_id => 1, :detail => 'xinjiekou')
        @location_event= Event.create(:title => 'Test event status', :description => 'Test event model',
                                     :start_at => Time.now.next_week, :end_at => Time.now.next_month,
                                     :subject_id => 1, :location=> @location)
    end

    after(:all) do
      @location_event.destroy
      @location.destroy
    end
    
    context 'test scope at_city' do
      it 'when event is at specialized city' do
        city_id = @location.city_id
        Event.at_city(city_id).should include(@location_event)
      end
      it 'when event is not at specialized city' do
        city_id = @location.city_id  + 1
        Event.at_city(city_id).should_not include(@location_event)
      end
    end

    context 'test scope at_district' do
      it 'when event is at specialized district' do
        district_id = @location.district_id
        Event.at_district(district_id).should include(@location_event)
      end
      it 'when event is not at specialized district' do
        district_id = @location.district_id  + 1
        Event.at_district(district_id).should_not include(@location_event)
      end
    end
  end

  describe 'get event by audit stauts scope' do
      before(:each) do
        @location = Location.create(:city_id => 1, :district_id => Event::DENIED, :detail => 'xinjiekou')
        @event= Event.create(:title => 'Test event status', :description => 'Test event model',
                             :start_at => Time.now.next_week, :end_at => Time.now.next_month,
                             :subject_id => 1, :location=> @location)
      end

      after(:each) do
        @event.destroy
        @location.destroy
      end
    context 'when event is waiting to be audited' do
      it 'test scope pass_audit' do
        Event.pass_audit.should_not include(@event)
      end
      it 'test scope to_be_audit' do
        Event.to_be_audit.should include(@event)
      end
      it 'test scope audit_failed' do
        Event.audit_failed.should_not include(@event)
      end
      it 'test scope canceled' do
        Event.canceled.should_not include(@event)
      end
    end 

    context 'when event has been denied' do
      let(:event){@event.update_attributes(:status => Event::DENIED); @event}
      it 'test scope pass_audit' do
        Event.pass_audit.should_not include(event)
      end
      it 'test scope to_be_audit' do
        Event.to_be_audit.should_not include(event)
      end
      it 'test scope audit_failed' do
        Event.audit_failed.should include(event)
      end
      it 'test scope canceled' do
        Event.canceled.should_not include(event)
      end
    end 

    context 'when event is has passed audit' do
      let(:event){@event.update_attributes(:status => Event::PASSED); @event}
      it 'test scope pass_audit' do
        Event.pass_audit.should include(event)
      end
      it 'test scope to_be_audit' do
        Event.to_be_audit.should_not include(event)
      end
      it 'test scope audit_failed' do
        Event.audit_failed.should_not include(event)
      end
      it 'test scope canceled' do
        Event.canceled.should_not include(event)
      end
    end 
    
    context 'when event has been canceled' do
      let(:event){@event.update_attributes(:status => Event::CANCELED_BY_EVENT_ADMIN); @event}
      it 'test scope pass_audit' do
        Event.pass_audit.should_not include(event)
      end
      it 'test scope to_be_audit' do
        Event.to_be_audit.should_not include(event)
      end
      it 'test scope audit_failed' do
        Event.audit_failed.should_not include(event)
      end
      it 'test scope canceled' do
        Event.canceled.should include(event)
      end
    end 
  end

  describe 'get event which is not full' do
    before(:all) do
        @location = Location.create(:city_id => 1, :district_id => 1, :detail => 'xinjiekou')
        @not_full_event= Event.create(:title => 'Test event status', :description => 'Test event model',
                                     :start_at => Time.now.next_week, :end_at => Time.now.next_month,
                                     :subject_id => 1, :location=> @location)
        @people = Array.new(10).fill{|i| Person.create(:user_id => (i+1))}
        @not_full_event.participants += @people
    end

    after(:all) do
      @not_full_event.destroy
      @location.destroy
      @people.each{ |p| p.destroy}
    end

    context 'test scope not_full' do
      it 'get event not full' do 
        @not_full_event.update_attributes(:participants_limit => 11)
        Event.not_full.should include(@not_full_event)
      end
      it 'get event not full should not get event full of members' do 
        @not_full_event.update_attributes(:participants_limit => 10)
        Event.not_full.should_not include(@not_full_event)
      end
    end
  end 

  describe '.update_avatar_urls' do
    pending
  end

  describe '.interested_event' do
    before(:all) do
      @events = []
      @items = []
      @locations = []
      1.upto(5).each do |i| 
        item = Item.create(:name => "item#{i}", :description => 'item#{i}', :category_id => 1)
        location = Location.create(:city_id => 1, :district_id => 1, :detail => 'xinjiekou')
        event= Event.create(:title => 'Test event status', :description => 'Test event model',
                                     :start_at => Time.now + 600, :end_at => Time.now + 3600,
                                     :subject_id => item.id, :location=> location)
        @events << event
        @items << item
        @locations << location
      end
      @person =  Person.create(:user_id => 89898)
      @person.interests << @items[0..2] 
    end

    after(:all) do
      @events.each {|e| e.destroy} 
      @locations.each {|l| l.destroy}
      @items.each {|i| i.destroy}
      @person.destroy
    end

    it 'test method interested_event' do
      city_id = @locations[0].city_id
      events = Event.interested_event(city_id, @person)
      events.size.should > 0
      t_events = [] + @events
      t_events.delete_if {|e| e.location.city_id != city_id || !@items[0..2].collect{|i| i.id }.include?(e.subject_id) }
      t_events.each {|e| events.should include(e)}
    end
  end

  describe '#image_url' do
    pending
  end

  describe '#is_ownver' do
    pending
  end

  describe '#participants_full?' do
    pending
  end

  describe '#participants_remained' do
    pending
  end

  describe 'test methods which get event status' do
    context 'when event is not started' do
      let(:event) {Event.new(:start_at => Time.now.tomorrow, :end_at => Time.now.tomorrow + 7200)}
      it '#not_started' do
        event.not_started?.should be_true
      end

      it '#ongoing' do
        event.ongoing?.should be_false
      end

      it '#over?' do
        event.over?.should be_false
      end
    end       

     context 'when event is ongoing' do
      let(:event) {Event.new(:start_at => Time.now - 3600, :end_at => Time.now+ 7200)}
      it '#not_started' do
        event.not_started?.should be_false
      end

      it '#ongoing' do
        event.ongoing?.should be_true
      end

      it '#over?' do
        event.over?.should be_false
      end
    end       
    
    context 'when event is over' do
      let(:event) {Event.new(:start_at => Time.now - 7200, :end_at => Time.now- 3600)}
      it '#not_started' do
        event.not_started?.should be_false
      end

      it '#ongoing' do
        event.ongoing?.should be_false
      end

      it '#over?' do
        event.over?.should be_true
      end
    end    

    context '#participants_full?' do
      let(:event){Event.new(:participants_limit => 50)}
      
      it 'when event pariticipants is not full' do
        event.participants_count = 49
        event.participants_full?.should be_false
      end

      it 'when event pariticipants is full' do
        event.participants_count = 50 
        event.participants_full?.should be_true
      end
    end
  end

  describe '#total_event_count' do
    pending
  end

  describe '#total_event_count' do
    pending
  end

  describe '#participants_top' do
    pending
  end

  describe '#references_top' do
    pending
  end

  describe '#joinable?' do
    pending
  end 

  describe '#quitable?' do
    pending
  end 

  describe '#owner' do
    pending
  end 

  describe '.filter_event' do
    pending
  end 

  describe '.filter_event_by_time' do
    pending
  end 

  describe '#need_notice?' do
    pending
  end 

  describe '#in_audit_process?' do
    pending
  end 
end
