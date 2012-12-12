require "spec_helper"

describe SitePostsController do
  describe "routing" do

    it "routes to #index" do
      get("/site_posts").should route_to("site_posts#index")
    end

    it "routes to #new" do
      get("/site_posts/new").should route_to("site_posts#new")
    end

    it "routes to #show" do
      get("/site_posts/1").should route_to("site_posts#show", :id => "1")
    end

    it "routes to #edit" do
      get("/site_posts/1/edit").should route_to("site_posts#edit", :id => "1")
    end

    it "routes to #create" do
      post("/site_posts").should route_to("site_posts#create")
    end

    it "routes to #update" do
      put("/site_posts/1").should route_to("site_posts#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/site_posts/1").should route_to("site_posts#destroy", :id => "1")
    end

  end
end
