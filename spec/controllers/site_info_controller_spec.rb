require 'spec_helper'

describe SiteInfoController do

  describe "GET 'feedback'" do
    it "should be successful" do
      get 'feedback'
      response.should be_success
    end
  end

end
