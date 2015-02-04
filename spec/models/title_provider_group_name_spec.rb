require 'spec_helper'

describe "TitleProviderGroupName" do

  let(:title_provider_group_name) { TitleProviderGroupName.make }
  let(:provider) { Provider.make }
  let(:title) { Title.make }
  let(:country) { Country.make }

  it "should allow creation with name and country" do
    my_tpgn = TitleProviderGroupName.make(:name => 'My group', :country_id => country.id)
    my_tpgn.should be_valid
  end

  it "should not allow duplicated names in a country" do
    my_tpgn1 = TitleProviderGroupName.make(:name => 'My group1', :country_id => country.id)
    my_tpgn2 = TitleProviderGroupName.make_unsaved(:name => 'My group1', :country_id => country.id)
    my_tpgn2.should_not be_valid
    my_tpgn2.errors[:name].should include "has already been taken"
  end

  it "should allow duplicated names with different countries" do
    my_tpgn1 = TitleProviderGroupName.make(:name => 'My group2', :country_id => country.id)
    my_tpgn2 = TitleProviderGroupName.make(:name => 'My group2', :country_id => Country.make.id)
    my_tpgn2.should be_valid
  end

  it "should order providers by name through title_provider_groups" do
    my_tpgn = title_provider_group_name
    my_tpgn.title_provider_groups.make(:provider => Provider.make(:name => 'c'))
    my_tpgn.title_provider_groups.make(:provider => Provider.make(:name => 'a'))
    my_tpgn.title_provider_groups.make(:provider => Provider.make(:name => 'b'))
    my_tpgn.title_provider_groups.collect{|tpg| tpg.provider.name}.should == ['a','b','c']

  end
  pending "to be continued ..."

end