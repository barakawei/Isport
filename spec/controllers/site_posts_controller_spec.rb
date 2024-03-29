require 'spec_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

describe SitePostsController do

  # This should return the minimal set of attributes required to create a valid
  # SitePost. As you add validations to SitePost, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    {}
  end

  describe "GET index" do
    it "assigns all site_posts as @site_posts" do
      site_post = SitePost.create! valid_attributes
      get :index
      assigns(:site_posts).should eq([site_post])
    end
  end

  describe "GET show" do
    it "assigns the requested site_post as @site_post" do
      site_post = SitePost.create! valid_attributes
      get :show, :id => site_post.id.to_s
      assigns(:site_post).should eq(site_post)
    end
  end

  describe "GET new" do
    it "assigns a new site_post as @site_post" do
      get :new
      assigns(:site_post).should be_a_new(SitePost)
    end
  end

  describe "GET edit" do
    it "assigns the requested site_post as @site_post" do
      site_post = SitePost.create! valid_attributes
      get :edit, :id => site_post.id.to_s
      assigns(:site_post).should eq(site_post)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new SitePost" do
        expect {
          post :create, :site_post => valid_attributes
        }.to change(SitePost, :count).by(1)
      end

      it "assigns a newly created site_post as @site_post" do
        post :create, :site_post => valid_attributes
        assigns(:site_post).should be_a(SitePost)
        assigns(:site_post).should be_persisted
      end

      it "redirects to the created site_post" do
        post :create, :site_post => valid_attributes
        response.should redirect_to(SitePost.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved site_post as @site_post" do
        # Trigger the behavior that occurs when invalid params are submitted
        SitePost.any_instance.stub(:save).and_return(false)
        post :create, :site_post => {}
        assigns(:site_post).should be_a_new(SitePost)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        SitePost.any_instance.stub(:save).and_return(false)
        post :create, :site_post => {}
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested site_post" do
        site_post = SitePost.create! valid_attributes
        # Assuming there are no other site_posts in the database, this
        # specifies that the SitePost created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        SitePost.any_instance.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => site_post.id, :site_post => {'these' => 'params'}
      end

      it "assigns the requested site_post as @site_post" do
        site_post = SitePost.create! valid_attributes
        put :update, :id => site_post.id, :site_post => valid_attributes
        assigns(:site_post).should eq(site_post)
      end

      it "redirects to the site_post" do
        site_post = SitePost.create! valid_attributes
        put :update, :id => site_post.id, :site_post => valid_attributes
        response.should redirect_to(site_post)
      end
    end

    describe "with invalid params" do
      it "assigns the site_post as @site_post" do
        site_post = SitePost.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        SitePost.any_instance.stub(:save).and_return(false)
        put :update, :id => site_post.id.to_s, :site_post => {}
        assigns(:site_post).should eq(site_post)
      end

      it "re-renders the 'edit' template" do
        site_post = SitePost.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        SitePost.any_instance.stub(:save).and_return(false)
        put :update, :id => site_post.id.to_s, :site_post => {}
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested site_post" do
      site_post = SitePost.create! valid_attributes
      expect {
        delete :destroy, :id => site_post.id.to_s
      }.to change(SitePost, :count).by(-1)
    end

    it "redirects to the site_posts list" do
      site_post = SitePost.create! valid_attributes
      delete :destroy, :id => site_post.id.to_s
      response.should redirect_to(site_posts_url)
    end
  end

end
