require 'spec_helper'

describe UsersController do
  describe 'getting_started' do
    it 'does not fail miserably' do
      get :getting_started
      response.should be_success
    end
  end

end
