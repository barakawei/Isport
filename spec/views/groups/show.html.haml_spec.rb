require 'spec_helper'

describe "groups/show.html.haml" do
  before(:each) do
    @group = assign(:group, stub_model(Group,
      :name => "Name",
      :description => "Description",
      :item_id => 1,
      :city_id => 1,
      :is_private => false,
      :join_mode => "Join Mode"
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Name/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Description/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/1/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/1/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/false/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Join Mode/)
  end
end
