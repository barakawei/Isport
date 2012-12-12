require 'spec_helper'

describe "site_posts/show.html.haml" do
  before(:each) do
    @site_post = assign(:site_post, stub_model(SitePost,
      :person_id => 1,
      :title => "Title",
      :content => "MyText"
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/1/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Title/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/MyText/)
  end
end
