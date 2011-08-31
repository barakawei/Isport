require 'spec_helper'

describe "site_posts/edit.html.haml" do
  before(:each) do
    @site_post = assign(:site_post, stub_model(SitePost,
      :person_id => 1,
      :title => "MyString",
      :content => "MyText"
    ))
  end

  it "renders the edit site_post form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => site_posts_path(@site_post), :method => "post" do
      assert_select "input#site_post_person_id", :name => "site_post[person_id]"
      assert_select "input#site_post_title", :name => "site_post[title]"
      assert_select "textarea#site_post_content", :name => "site_post[content]"
    end
  end
end
