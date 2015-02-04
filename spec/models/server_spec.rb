require 'spec_helper'

describe Server do

  it { should have_many :titles }
  it { should have_many :net_messages }

  it { should validate_presence_of :name }


  it "should validates uniqueness of name" do
    server = Server.make
    should validate_uniqueness_of :name
  end

  it "should not allow duplicate names with different cases" do 
    server = Server.make
    other_server = Server.make_unsaved(:name => server.name.upcase)
    other_server.should_not be_valid
    other_server.errors[:name].should include "has already been taken"
  end

  it "should have only one self" do
    server_one, server_two = Server.make(:is_self => true), Server.make(:is_self => true)
    server_one.reload.is_self.should == false
  end

end
