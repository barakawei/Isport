require  'spec_helper'

describe Item do
  before(:all) do 
    @item1 = Item.create(:name => "ItemOne", :description => "no desc", :category_id => 1) 
    @item2 = Item.create(:name => "ItemTwo", :description => "no desc", :category_id => 1)
    @location = Location.create(:city_id => 1, :district_id => 1, :detail => 'zhujianglu')
    @numbers = Array.new(10).fill{|i| i+1}
    @people = Array.new(10).fill{|i| Person.create(:user_id => (i+1))}
    
    @events = [  ]
    @numbers.each_with_index do |n, index|
      @events.push(Event.create(:title => 'Test event model', :description => 'Test event model',
                            :start_at => Time.now.next_week + index, :end_at => Time.now.next_month + index,
                            :subject_id => @item1.id, :location=> @location, :status => 2))
    end

    @groups = [  ]
    @numbers.each do |i|
      @groups.push(Group.create(:name => 'Test group model', :description => 'Test Group',
                            :item_id => @item1.id, :city_id => 1, :district_id => 1, :join_mode => 1, :status => 2))

    end

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
    @groups.each { |g| g.destroy }
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
      @item1.events_count.should == 9
    end

    it "item events_count should change when event change" do
      event = Event.find(@events.first.id)
      event.update_attributes(:subject_id => @item2.id)

      @item1.reload
      @item2.reload

      @item2.events_count.should == @item2.events.count
      @item2.events_count.should == 1

      @item1.events_count.should == @item1.events.count
      @item1.events_count.should == 9
    end

    it "item groups_count should equal to groups.count" do 
      @item1.groups_count.should == @item1.groups.count
      @item1.groups_count.should == 10
    end
  
    it "item groups_count should decrease when groups destroy" do 
      @groups.first.destroy
      @item1.reload

      @item1.groups_count.should == @item1.groups.count
      @item1.groups_count.should == 9
    end

    it "item groups_count shound change when group update attributes" do
      group = Group.find(@groups.first.id)
      group.update_attributes(:item_id => @item2.id)

      @item1.reload
      @item2.reload

      @item2.groups_count.should == @item2.groups.count
      @item2.groups_count.should == 1
     
      @item1.groups_count.should == @item1.groups.count
      @item1.groups_count.should == 9
    end
  end

  context "test functions" do 
    it "hot item should be item1" do 
      items = Item.hot_items(2, nil)
      items[0].should == @item1
    end      
  end
end

