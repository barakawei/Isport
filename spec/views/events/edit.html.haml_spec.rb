require 'spec_helper'

describe "events/edit.html.haml" do
  before(:each) do
    @event = assign(:event, stub_model(Event,
      :title => "MyString",
      :description => "MyText",
      :location => "MyString",
      :subject_id => 1,
      :ispublic => false
    ))
  end

  it "renders the edit event form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => events_path(@event), :method => "post" do
      assert_select "input#event_title", :name => "event[title]"
      assert_select "textarea#event_description", :name => "event[description]"
      assert_select "input#event_location", :name => "event[location]"
      assert_select "input#event_subject_id", :name => "event[subject_id]"
      assert_select "input#event_ispublic", :name => "event[ispublic]"
    end
  end
end
