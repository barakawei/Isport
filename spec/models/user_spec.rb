require 'spec_helper'

describe User do
  describe ".build" do
    context 'with valid params' do
      before do
        params = {
                  :email => "ohai@example.com",
                  :password => "password",
                  :password_confirmation => "password",
                  :person =>
                    {:profile =>
                      {:name => "hello"}
                    }
        }
        @user = User.build(params)
      end

      it "does not save" do
        @user.persisted?.should be_false
        @user.person.persisted?.should be_false
        User.find_by_email("ohai@example.com").should be_nil
      end

      it 'saves successfully' do
        @user.should be_valid
        @user.save.should be_true
        @user.persisted?.should be_true
        @user.person.persisted?.should be_true
        User.find_by_email("ohai@example.com").should == @user
      end
    end  
  end
end
