require 'spec_helper'

describe Group do
  context 'when initialized' do
    let(:group) {Group.new}
    it 'join_mode should be free default' do
      group.join_mode.should == Group::JOIN_FREE 
    end
  end

  context 'when created with not valid attributes' do
    before do
      @group = Factory.build(:group)
    end

    it 'name can not be nil' do
      @group.name = nil
      @group.should_not be_valid  
      @group.save
      @group.errors[:name][0].should == I18n.t('activerecord.errors.messages.blank')
    end
    
    it 'description can not be nil' do
      @group.description = nil
      @group.should_not be_valid
      @group.save
      @group.errors[:description][0].should == I18n.t('activerecord.errors.messages.blank')
    end

    it 'item_id can not be nil' do
      @group.item_id= nil
      @group.should_not be_valid
      @group.save
      @group.errors[:item_id][0].should == I18n.t('activerecord.errors.messages.blank')
    end
    
    it 'city_id can not be nil' do
      @group.city_id= nil
      @group.should_not be_valid
      @group.save
      @group.errors[:city_id][0].should == I18n.t('activerecord.errors.messages.blank')
    end

    it 'district_id can not be nil' do
      @group.district_id= nil
      @group.should_not be_valid
      @group.save
      @group.errors[:district_id][0].should == I18n.t('activerecord.errors.messages.blank')
    end

    it 'join_mode can not be nil' do
      @group.join_mode= nil
      @group.should_not be_valid
      @group.save
      @group.errors[:join_mode][0].should == I18n.t('activerecord.errors.messages.blank')
    end

    it 'name should not more than 30 characters' do
      @group.name = 'i' * 31
      @group.should_not be_valid
      @group.save
      @group.errors[:name][0].should == I18n.t('activerecord.errors.messages.too_long', :count => 30)
    end

    it 'description should not more than 3000 characters' do
      @group.description= 'i' * 3001
      @group.should_not be_valid
      @group.save
      @group.errors[:description][0].should == I18n.t('activerecord.errors.messages.too_long', :count => 3000)
    end
  end

  context 'test group scope' do
    before do
      @group = Factory.build(:group)
      @city = Factory.build(:city, :id => 1)
      @item = Factory.create(:item)
    end
    
    it 'test scope at_city' do 
      @group.city_id = @city.id 
      @group.item_id = @item.id
      @group.save
      Group.at_city(@city).should include(@group)
    end 

    it 'test scope of_item' do
      @group.item_id = @item.id
      @group.save
      Group.of_item(@item).should include(@group)
    end
  end

  context 'test has_many relationships' do
    before do
      @item = Factory.create(:item)
      @group = Factory.create(:group, :item_id => @item.id)
    end
    it '#events' do
      @events = Factory.create_list(:event, 5, :group_id => @group.id, :item_id => @item.id)
      @group.events.size.should == 0 
      @passed_event = @events[0]
      @passed_event.update_attributes(:status => Event::PASSED)
      @group.reload
      @group.events.should include(@passed_event)  
    end

    it '#members' do
      @people= Factory.create_list(:person, 5)
      @people.each do |p|
        Factory.create(:membership, :person_id => p.id, :group_id => @group.id)
      end
      @group.members.size.should == 0
      
    end
  end
end
