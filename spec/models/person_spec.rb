require 'spec_helper'

describe Person do
  describe '.search' do
    before do
      @user = Factory.create(:user)
      @user.person.profile.name = 'sun'
      @user.save

      @person1 = Factory.create(:person)
      @person2 = Factory.create(:person)
      @person3 = Factory.create(:person)
      @person4 = Factory.create(:person)
      @person1.save
      @person2.save
      @person3.save
      @person4.save

      @person1.profile.name = "Robert"
      @person1.profile.save
      @person1.reload

      @person2.profile.name = "Eugene"
      @person2.profile.save
      @person2.reload

      @person3.profile.name = "Yevgeniy"
      @person3.profile.save
      @person3.reload

      @person4.profile.name = "Casey"
      @person4.profile.save
      @person4.reload
    end

    it 'should return nothing on an empty query' do
      people = Person.search("", @user)
      people.empty?.should be true
    end

    it 'should yield search results on partial names' do
      people = Person.search("Eug", @user)
      people.size.should == 1
      people.first.should == @person2

      people = Person.search("Eug Yev", @user)
      people.size.should == 2 
      people.first.should == @person2
      people.second.should == @person3


      people = Person.search("gen", @user)
      people.size.should == 2
      people.first.should == @person2
      people.second.should == @person3
    end

    it 'gives results on full names' do
      people = Person.search("Casey", @user)
      people.size.should == 1
      people.first.should == @person4
    end

    it "puts the searching user's contacts first" do
      @person1.profile.name = "AAA"
      @person1.profile.save

      @person2.profile.name = "AAA"
      @person2.profile.save

      @person3.profile.name = "AAA"
      @person3.profile.save

      @person4.profile.name = "AAA"
      @person4.profile.save

      @user.contacts.create(:person => @person4)

      people = Person.search("AAA", @user)
      people.map { |p| p.name }.should == [@person4, @person1, @person2, @person3].map { |p| p.name }
    end
  end
end
