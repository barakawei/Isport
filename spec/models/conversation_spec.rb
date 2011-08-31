require 'spec_helper'

describe Conversation do
  before do
    @user1 = Factory.build(:user,:email=>'123@123.com')
    @user2 = Factory.build(:user,:email=>'234@234.com')
    @contact1 = Factory.build(:contact,:user=>@user1,:person => @user2.person,:receiving =>true,:sharing =>true)
    @contact2 = Factory.build(:contact,:user=>@user2,:person => @user1.person,:receiving =>true,:sharing=>true)
    @contact1.save
    @contact2.save
    @participant_ids = [@user1.contacts.first.person.id, @user1.person.id]

    @create_hash = { :person => @user1.person, :participant_ids => @participant_ids ,
                     :subject => "cool stuff", :text => 'hey'}
  end

  it 'creates a message on create' do
    lambda{
      Conversation.create(@create_hash)
    }.should change(Message, :count).by(1)
  end

  describe '#last_author' do
    it 'returns the last author to a conversation' do
      cnv = Conversation.create(@create_hash)
      Message.create(:person => @user2.person, :created_at => Time.now + 100, :text => "last", :conversation_id => cnv.id)
      cnv.reload.last_author.id.should == @user2.person.id
    end
  end
end
