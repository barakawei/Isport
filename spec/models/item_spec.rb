require  'spec_helper'

describe Item do
  before(:all) do 
    @item1 = Item.create(:name => "ItemOne", :description => "no desc", :category_id => 1) 
    @item2 = Item.create(:name => "ItemTwo", :description => "no desc", :category_id => 1)

    @location = Location.create(:city_id => 1, :district_id => 1, :detail => 'zhujianglu')

    @people = Array.new(10).fill{|i| Person.create(:user_id => (i+1))}

    @events = Array.new(10).fill{|e| Event.create(:title => 'Test event model', :description => 'Test event model',
                            :start_at => Time.now.next_week + e.hour, :end_at => Time.now.next_week + e.day,
                            :subject_id => 1, :location=> @location, :status => 2)}

  
    @people[0...6].each do |person|
      Item.add_fan(@item1.id, person)
    end

    @people[4...9].each do |person|
      Item.add_fan(@item2.id, person)
    end

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
    end

    it "item fans_count should increase when new member added" do
      @people[7...9].each do |person|
        Item.add_fan(@item1.id, person) 
      end
      @item1.fans_count.should == @item1.fans.count 
    end

    it "item fans_count should decrease when some one leave" do
      @people[3...6].each do |person|
        Item.remove_fan(@item1.id, person)
      end
      @item1.fans_count.should == @item1.fans.count 
    end
  end

end
