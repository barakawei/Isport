require 'spec_helper'

describe User do
  describe ".build" do
    context 'with valid params' do
      before do
        params = {
                  :email => "ohai@example.com",
                  :password => "password",
                  :password_confirmation => "password",
        }
        @user = User.build(params)
      end

      it "does not save" do
        @user.persisted?.should be_false
        @user.person.persisted?.should be_false
        @user.person.profile.persisted?.should be_false
        User.find_by_email("ohai@example.com").should be_nil
      end

      it 'saves successfully' do
        @user.should be_valid
        @user.person.profile.should be_valid
        @user.save.should be_true
        @user.persisted?.should be_true
        @user.person.persisted?.should be_true
        @user.person.profile.persisted?.should be_true
        User.find_by_email("ohai@example.com").should == @user
      end
    end  

    context "with invalid params" do
      before do
        @invalid_params = {
          :email => "ohai@example.com",
          :password => "password",
          :password_confirmation => "wrongpasswordz",
          }
      end

      it "raises no error" do
        lambda { User.build(@invalid_params) }.should_not raise_error
      end

      it "does not save" do
        User.build(@invalid_params).save.should be_false
      end

      it 'does not save a person' do
        lambda { User.build(@invalid_params) }.should_not change(Person, :count)
      end
    end
  end
  
  describe "validation" do
    describe "of email" do

      before do
        @user = Factory.build(:user)
      end

      it "email can not be nil" do
        @user.email = nil
        @user.should_not be_valid
      end

      it "email can not be ''" do
        @user.email = ''
        @user.should_not be_valid
      end

      it "email must be valid" do
        @user.email = "somebody@anywhere"
        @user.should_not be_valid
      end
    end
  end



  describe '#update_profile' do
    before do
      @params = {
        :name => 'hello'
      }
      @user = Factory.build(:user)
      @user.save!
    end

    it 'updates name' do
      @user.update_profile(@params).should be_true
      @user.reload.profile.name.should == 'hello'
    end

    it 'updates image_url' do
      params = {:image_url => "http://alyosha.com"}

      @user.update_profile(params).should be_true
      @user.reload.profile.image_url.should == "http://alyosha.com"
    end

    context 'upload a photo' do
      before do
        photo_filename  = 'user.png'
        photo_name = File.join(File.dirname(__FILE__), '..', 'fixtures', photo_filename)
        image = File.open(photo_name)
        @photo = Photo.initialize({:user_file => image},'192.168.1.1','3000',@user.person)
        @photo.save!
        @params = {:photo => @photo}
      end

      it 'updates image_url' do
        @user.update_profile(@params).should be_true
        @user.reload
        @user.profile.image_url.should =~ Regexp.new(@photo.url(:thumb_large))
        @user.profile.image_url_medium.should =~ Regexp.new(@photo.url(:thumb_medium))
        @user.profile.image_url_small.should =~ Regexp.new(@photo.url(:thumb_small))
      end
    end
  end

  describe '#share_with' do
    before do
      @user1 = Factory.build(:user,:email=>'123@123.com')
      @user2 = Factory.build(:user,:email=>'234@234.com')
      @user1.save!
      @user2.save!
    end
    it 'can follow person without contact' do
      contact = @user1.share_with( @user2.person )
      @user1.contacts.size.should == 1
      @user1.contacts.first.should == contact
      @user1.contacts.first.person.should == @user2.person
      @user1.contacts.first.receiving.should be_true
      @user1.contacts.first.sharing.should be_false
      @user1.followed_people.size.should == 1
      @user1.followed_people.first.should == @user2.person
      @user1.befollowed_people.size.should == 0
      @user2.followed_people.size.should == 0 
      @user2.befollowed_people.size.should == 1
      @user2.befollowed_people.first.should == @user1.person
    end

    it 'can follow person with contact' do
      contact1 = Factory.build(:contact,:user=>@user1,:person => @user2.person,:receiving =>false,:sharing=>true)
      contact2 = Factory.build(:contact,:user=>@user2,:person => @user1.person,:receiving =>true,:sharing=>false)
      contact1.save!
      contact2.save!
      @user1.share_with( @user2.person )
      contact1.reload.receiving.should be_true
      contact2.reload.sharing.should be_true
      @user1.followed_people.size.should == 1
      @user1.followed_people.first.should == @user2.person
      @user1.befollowed_people.size.should == 1
      @user1.befollowed_people.first.should == @user2.person
      @user2.followed_people.size.should == 1
      @user2.followed_people.first.should == @user1.person
      @user2.befollowed_people.size.should == 1
      @user2.befollowed_people.first.should == @user1.person

    end
  end

  describe '#remove_person' do
    before do
      @user1 = Factory.build(:user,:email=>'123@123.com')
      @user2 = Factory.build(:user,:email=>'234@234.com')
      @user1.save!
      @user2.save!
    end
    
    it 'can remove person with single contact' do
      contact1 = Factory.build(:contact,:user=>@user1,:person => @user2.person,:receiving =>true,:sharing =>false)
      contact2 = Factory.build(:contact,:user=>@user2,:person => @user1.person,:receiving =>false,:sharing=>true)
      contact1.save!
      contact2.save!
      @user1.remove_person( @user2.person )
      Contact.where( :id => contact1.id ).should be_empty
      Contact.where( :id => contact2.id ).should be_empty
      
    end

    it 'can remove person with mutual contact' do
      contact1 = Factory.build(:contact,:user=>@user1,:person => @user2.person,:receiving =>true,:sharing =>true)
      contact2 = Factory.build(:contact,:user=>@user2,:person => @user1.person,:receiving =>true,:sharing=>true)
      contact1.save!
      contact2.save!
      @user1.remove_person( @user2.person )
      contact1.reload.should_not be_nil
      contact2.reload.should_not be_nil
      @user1.followed_people.should be_empty
      @user1.befollowed_people.first.should == @user2.person
      @user2.befollowed_people.should be_empty
      @user2.followed_people.first.should == @user1.person
    end
  end

end
