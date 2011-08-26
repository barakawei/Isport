require 'spec_helper'

describe Profile do
  describe "validation" do
    describe "of name" do
      before do
        @profile = Factory.build(:profile)
      end

      it "name can not be nil" do
        @profile.name = nil
        @profile.should_not be_valid
      end

      it "name can not be ''" do
        @profile.name = '  '
        @profile.should_not be_valid
      end

      it "downcases name" do
        @profile.name = 'GOOD'
        @profile.should be_valid
        @profile.name.should == "good"
      end


      it "trip name" do
        @profile.name = "     like"
        @profile.should be_valid
        @profile.name.should == "like"
      end

      it 'can not contain ;' do
        @profile.name = "kittens;"
        @profile.should_not be_valid
      end

      it 'can contain _' do
        @profile.name = "_kit_tens_"
        @profile.should be_valid
      end


      it 'can not contain .' do
        @profile.name = "kittens."
        @profile.should_not be_valid
      end

      it "can be 20 characters long" do
        @profile.name = "12345678901234567890"
        @profile.should be_valid
      end

      it "cannot be 21 characters" do
        @profile.name =  "123456789012345678901"
        @profile.should_not be_valid
      end

    end
  end
end
