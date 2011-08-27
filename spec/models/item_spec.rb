require  'spec_helper'

describe Item do
  before(:all) do 
    @item1 = Item.create(:name => "ItemOne", :description => "no desc", :category_id => 1) 
    @item2 = Item.create(:name => "ItemTwo", :description => "no desc", :category_id => 1)
    @location = Location.create(:city_id => 1, :district_id => 1, :detail => 'zhujianglu')

    @people = Array.new(10).fill{|i| Person.create(:user_id => (i+1))}

    @events = Array.new(10).fill{|e| Event.create(:title => 'Test event model', :description => 'Test event model',
                            :start_at => Time.now.next_week + e.hour, :end_at => Time.now.next_week + e.day,
                            :subject_id => @item1.id, :location=> @location, :status => 2)}

    @people[0...6].each do |person|
      Item.add_fan(@item1.id, person)
    end

    @people[6...10].each do |person|
      Item.add_fan(@item2.id, person)
    end
  
    @item1.reload
    @item2.reload
  end

  after(:all) do
    @people.each{ |p| p.destroy }
    @events.each { |e| e.destroy }
    @location.destroy
    @item1.destroy
    @item2.destroy
  end

  context "text counter cache"  do 
    it "item fans_count should equal to fans.count"  do
      @item1.fans_count.should == @item1.fans.count
      @item1.fans_count.should == 6
    end

    it "item fans_count should increase when new member added" do
      @people[6...10].each do |person|
        Item.add_fan(@item1.id, person) 
      end

      @item1.reload
      @item1.fans_count.should == @item1.fans.count 
      @item1.fans_count.should == 10
    end

    it "item fans_count should decrease when some one leave" do
      @people[3...6].each do |person|
        Item.remove_fan(@item1.id, person)
      end
      @item1.reload
      @item1.fans_count.should == @item1.fans.count
      @item1.fans_count.should == 3
    end

    it "item events_count should equal to events.count" do 
      @item1.events_count.should == @item1.events.count
      @item1.events_count.should == 10
    end

    it "item events_count should decrease when event deleted" do 
      @events.first.destroy
      @item1.reload
      @item1.events_count.should == @item1.events.count
    end

    it "item events_count should increase when event create" do 
      add_event = Event.create(:title => 'Test event model', :description => 'Test event model',
                            :start_at => Time.now.next_week + 1.hour, :end_at => Time.now.next_week + 1.day,
                            :subject_id => @item2.id, :location=> @location, :status => 2)
      add_event.save
      @item2.reload
      @item2.events_count.should == @item2.events.count
      @item2.events_count.should == 1
      add_event.destroy
    end

    it "item events_count should change when event change" do 
      add_event = Event.create(:title => 'Test event model', :description => 'Test event model',
                            :start_at => Time.now.next_week + 1.hour, :end_at => Time.now.next_week + 1.day,
                            :subject_id => @item2.id, :location=> @location, :status => 2) 
      add_event.save
      @item2.reload
      @item2.events_count.should == @item2.events.count
      @item2.events_count.should == 1

      add_event.update_attributes(:subject_id => 2)
      add_event.save

      @item1.reload
      @item1.events_count.should == @item1.events.count
      @item1.events_count.should == 11
      add_event.destroy
      @item2.reload
      @item2.events_count.should == 0
    end


  end

end
