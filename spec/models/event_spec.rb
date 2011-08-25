require 'spec_helper'

describe Event do
  before(:all) do
    @location = Location.create(:city_id => 1, :district_id => 1, :detail => 'zhujianglu')
    @test_event = Event.create(:title => 'Test event model', :description => 'Test event model',
                               :start_at => Time.now.next_week, :end_at => Time.now.next_month,
                               :subject_id => 1, :location=> @location)
    @people = Array.new(10).fill{|i| Person.create(:user_id => (i+1))}
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
end
