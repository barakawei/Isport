require 'spec_helper'

describe HomeController do
  describe '#index' do
    before do
      @user = Factory.build( :user )
    end

    it 'redirect to getting_started if user is first logged in' do
      @user.getting_started = true
      @user.save
      sign_in @user
      get :index
      response.should redirect_to getting_started_path
    end

    it 'redirect to home if user has init' do
      @user.getting_started = false
      @user.save
      sign_in @user
      get :index
      response.should be_success
    end

  end
end
