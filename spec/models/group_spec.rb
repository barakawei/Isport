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
    end
    
    it 'test scope at_city' do 
      @group.city_id = @city.id 
      @group.save
      Group.at_city(@city).should include(@group)
    end 

    it 'test scope of_item' do
      @item = Factory.create(:item)
      @group.item = @item
      @group.save
      Group.of_item(@item).should include(@group)
    end
  end

  context 'test has_many relationships' do
    before do
      @group = Factory.create(:group)
    end
    it '#events' do
      @item = Factory.create(:item)
      @events = FactoryGirl.create_list(:event, 5, :group_id => @group.id, :subject_id => @item.id)
      @group.events.size.should == 0 
      @passed_event = @events[0]
      @passed_event.update_attributes(:status => Event::PASSED)
      @group.reload
      @group.events.should include(@passed_event)  
    end

    it '#members' do
      @group.reload
      @group.members.size.should == @group.members.count 
    end

    it '#invitees' do
      p = @group.members.first
      @group.memberships.first.update_attributes(:pending => 'true', :pending_type => Group::JOIN_BY_INVITATION_FROM_ADMIM)
      @group.reload
      p.reload
      @group.invitees.should include(p)
    end

    it '#applicants' do
      p = @group.members.first
      @group.memberships.first.update_attributes(:pending => 'true', :pending_type => Group::JOIN_AFTER_AUTHENTICATAION)
      @group.reload
      p.reload
      @group.applicants.should include(p)
    end

    it '#deletable_members' do
      p = @group.members.first
      @group.memberships.first.update_attributes(:pending => false, :is_admin=> false)
      p.reload
      @group.reload
      @group.deletable_members.should include(p)
    end

    it '#admins' do
      p = @group.members.first
      @group.memberships.first.update_attributes(:is_admin => true)
      @group.reload
      p.reload
      @group.admins.should include(p)
    end
  end

  describe '.interested_groups' do
    before do
      @city = Factory.create(:city) 
      @groups = FactoryGirl.create_list(:group, 20, :city_id => @city.id)
      @items = Item.all
      @person= Factory.create(:person)
      @person.interests += @items[0..10]
    end

    it 'get interested group' do
      i_groups = Group.interested_groups(@city, @person)
      i_groups.each_with_index do |g, index|
        @person.interests.should include(g.item) 
        if index < i_groups.length - 1
          g.members.size.should >= i_groups[index+1].members.size
        end
        g.city.should == @city
      end 
    end
  end

  describe '.hot_group_by_item' do
    before do
      @city = Factory.create(:city) 
      @items = []
      [1..4].each do
        @item = Factory.create(:item)
        @items << @item
        FactoryGirl.create_list(:group, 5, :city_id => @city.id, :item_id => @item.id)
      end
    end

    it 'find hot group by item' do
      item = @items.first
      hot_groups = Group.hot_group_by_item(@city, item) 
      hot_groups.each_with_index do |g, index|
        g.item.should == item
        g.city.should == @city
        if index < hot_groups.length - 1
          g.members.size > hot_groups[index+1].members.size
        end
      end
    end
  end

  describe '.joinable?' do
    context 'when group join_mode with different valudes' do
      before do
        @group = Factory.create(:group)
        @person  = Factory.create(:person)
      end

      it 'group join mode is JOIN_FREE' do
        @group.update_attributes(:join_mode => Group::JOIN_FREE)
        @group.joinable?(@person).should == true 
        @group.members << @person
        @group.joinable?(@person).should == false 
      end

      it 'group join mode is JOIN_AFTER_AUTHENTICATAION' do
        @group.update_attributes(:join_mode => Group::JOIN_AFTER_AUTHENTICATAION)
        @group.joinable?(@person).should == true 
        @group.members << @person
        @group.joinable?(@person).should == false 
        @m_ship = @group.memberships.find_by_person_id(@person.id)
        @m_ship.update_attributes(:pending => true)
        @group.joinable?(@person).should == false 
        @m_ship.update_attributes(:pending_type => Group::JOIN_BY_INVITATION_FROM_ADMIM)
        @group.joinable?(@person).should == true 
      end 

      it 'group join mode is JOIN_BY_INVITATION_FROM_ADMIM' do
        @group.update_attributes(:join_mode => Group::JOIN_BY_INVITATION_FROM_ADMIM)
        @group.joinable?(@person).should == false
        @group.members << @person
        @m_ship = @group.memberships.find_by_person_id(@person.id)
        @m_ship.update_attributes(:pending => true)
        @group.joinable?(@person).should == true 
      end
    end
 end

  describe '#add_member' do
    context 'when group join_mode with different valudes' do
      before do
        @group = Factory.create(:group)
        @person = Factory.create(:person)
      end

      it 'when join_mode is JOIN_AFTER_AUTHENTICATAION' do
        @group.update_attributes(:join_mode => Group::JOIN_AFTER_AUTHENTICATAION)
        @group.add_member(@person)
        @group.applicants.should include @person
        @group.add_member(@person)
        @group.reload
        @group.members.should include @person
      end

      it 'when join_mode is JOIN_FREE' do
        @group.update_attributes(:join_mode => Group::JOIN_FREE)
        @group.add_member(@person)
        @group.reload
        @group.members.should include @person
      end
    end
  end
end
