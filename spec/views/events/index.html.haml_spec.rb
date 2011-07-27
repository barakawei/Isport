require 'spec_helper'

describe "events/index.html.haml" do
  before(:each) do
    assign(:events, [
      stub_model(Event,
        :title => "Title",
        :description => "MyText",
        :location => "Location",
        :subject_id => 1,
        :ispublic => false
      ),
      stub_model(Event,
        :title => "Title",
        :description => "MyText",
        :location => "Location",
        :subject_id => 1,
        :ispublic => false
      )
    ])
  end

  it "renders a list of events" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Title".to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Location".to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => false.to_s, :count => 2
  end
end
