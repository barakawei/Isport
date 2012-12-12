require 'spec_helper'

describe "groups/new.html.haml" do
  before(:each) do
    assign(:group, stub_model(Group,
      :name => "MyString",
      :description => "MyString",
      :item_id => 1,
      :city_id => 1,
      :is_private => false,
      :join_mode => "MyString"
    ).as_new_record)
  end

  it "renders new group form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => groups_path, :method => "post" do
      assert_select "input#group_name", :name => "group[name]"
      assert_select "input#group_description", :name => "group[description]"
      assert_select "input#group_item_id", :name => "group[item_id]"
      assert_select "input#group_city_id", :name => "group[city_id]"
      assert_select "input#group_is_private", :name => "group[is_private]"
      assert_select "input#group_join_mode", :name => "group[join_mode]"
    end
  end
end
