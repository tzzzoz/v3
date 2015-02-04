require 'spec_helper'

describe SavedSearch do
  it { should belong_to :user }
  it { should validate_presence_of :name }

  it { should validate_presence_of :user_id }

  let(:user) { User.make }

  context "A new SavedSearch" do

    it "should not allow duplicate names for the same user" do
      search_one = SavedSearch.make(:name => "My search", :user => user)
      search_two = SavedSearch.make_unsaved(:name => "My search", :user => user)
      search_two.should_not be_valid
      search_two.errors[:name].should include "has already been taken"
    end

    it "should not allow duplicate names with different cases for the same user" do
      search_one = SavedSearch.make(:name => "MY SEARCH", :user => user)
      search_two = SavedSearch.make_unsaved(:name => "My search", :user => user)
      search_two.should_not be_valid
      search_two.errors[:name].should include "has already been taken"
    end

    it "should allow duplicate names for different user" do
      user_two = User.make
      search_one = SavedSearch.make(:name => "My search", :user => user)
      search_two = SavedSearch.make(:name => "My search", :user => user_two)
      search_two.should be_valid
    end

    it "should serialize criteria" do
      search = SavedSearch.make(:criteria => {:horizontal => true, :key_words => "Megan Fox" })
      search.criteria.keys.size.should == 2
      search.criteria.keys.should == [:horizontal, :key_words]
      search.criteria[:horizontal].should be true
      search.criteria[:key_words].should == "Megan Fox"
    end
  end # context

end
