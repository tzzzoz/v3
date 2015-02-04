require 'spec_helper'

describe Title do

  it { should have_many :users }
  it { should have_many :light_boxes }

  it { should belong_to :title_provider_group_name }
  it { should belong_to :server }
  it { should belong_to :country }

  it { should validate_presence_of :server_id }
  it { should validate_presence_of :country_id }
  it { should validate_presence_of :name }
  
   # TODO: no matchers for this in RSpec ?? Write one..
   # it { should validate_associated :server }
   # it { should validate_associated :country }

   let(:server) { Server.make }

   it "should not allow duplicate names for the same server" do
     title_one = Title.make(:name => "My title", :server => server)
     title_two = Title.make_unsaved(:name => "My title", :server => server)
     title_two.should_not be_valid
     title_two.errors[:name].should include "has already been taken"
   end
  
   it "should not allow duplicate names with different cases for the same server" do
     title_one = Title.make(:name => "MY TITLE", :server => server)
     title_two = Title.make_unsaved(:name => "My title", :server => server)
     title_two.should_not be_valid
     title_two.errors[:name].should include "has already been taken"
   end
   
   it "should allow duplicate names for different server" do
     server_two = Server.make
     title_one = Title.make(:name => "My title", :server => server)
     title_two = Title.make(:name => "My title", :server => server_two)
     title_two.should be_valid
   end
   
    it "should destroy light_boxes when the title is destroyed" do
     title = Title.make(:name => "My title", :server => server)
     lb = LightBox.make(:user => User.make, :name => "My LightBox", :title => title)
     title.destroy
     title.light_boxes.count.should == 0
   end
   
    it "should nullify user when the title is destroyed" do
     title = Title.make(:name => "My title", :server => server)
     user = User.make(:title => title)
     title.destroy
     user.reload.title_id.should be_nil
   end
end
