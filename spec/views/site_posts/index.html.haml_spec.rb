require 'spec_helper'

describe "site_posts/index.html.haml" do
  before(:each) do
    assign(:site_posts, [
      stub_model(SitePost,
        :person_id => 1,
        :title => "Title",
        :content => "MyText"
      ),
      stub_model(SitePost,
        :person_id => 1,
        :title => "Title",
        :content => "MyText"
      )
    ])
  end

  it "renders a list of site_posts" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Title".to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
  end
end
