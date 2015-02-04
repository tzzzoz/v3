require 'spec_helper'

describe SearchProviderGroupName do
  it { should belong_to  :user }
  it { should have_many   :search_provider_groups }
  it { should have_many   :providers }

  it { should validate_presence_of  :name }
  it { should validate_presence_of :user_id }

  describe "Defined class methods" do
    it "should respond to update_group" do
      SearchProviderGroupName.should respond_to(:update_group)
    end 
  end

  let(:user) { User.make }

  it "should not allow duplicate names for the same user" do
    group_one = SearchProviderGroupName.make(:name => "My Group", :user => user)
    group_two = SearchProviderGroupName.make_unsaved(:name => "My Group", :user => user)
    group_two.should_not be_valid
    group_two.errors[:name].should include "has already been taken"
  end

  it "should not allow duplicate names with different cases for the same user" do
    group_one = SearchProviderGroupName.make(:name => "MY GROUP", :user => user)
    group_two = SearchProviderGroupName.make_unsaved(:name => "My group", :user => user)
    group_two.should_not be_valid
    group_two.errors[:name].should include "has already been taken"
  end

  it "should allow duplicate names for different user" do
    other_user = User.make
    group_one = SearchProviderGroupName.make(:name => "My Group", :user => user)
    group_two = SearchProviderGroupName.make(:name => "My Group", :user => other_user)
    group_two.should be_valid
  end
 
  context "A new SearchProviderGroupName" do

    it "should respond to add_group" do
      group = SearchProviderGroupName.make(:name => "My Group", :user => user)
      group.should respond_to(:add_group)
    end

    it "should add providers to a group" do
      provider_one, provider_two = Provider.make, Provider.make
      group = SearchProviderGroupName.make(:name => "My group", :user_id => user.id)
      providers = [provider_one.id, provider_two.id]
      group.add_group(providers)
      group.save
      group.search_provider_groups.count.should == 2
      group.search_provider_groups.first.provider_id.should == provider_one.id
      group.search_provider_groups.last.provider_id.should == provider_two.id
    end

    it "should update a group for providers" do
      provider_one, provider_two = Provider.make, Provider.make
      params = {:provider_group_name => SearchProviderGroupName.make, :providers => [provider_one.id, provider_two.id]}
      group = SearchProviderGroupName.update_group(params)
      group.save
      group.search_provider_groups.count.should == 2
      group.search_provider_groups.first.provider_id.should == provider_one.id
      group.search_provider_groups.last.provider_id.should == provider_two.id
    end

  end # context
end
