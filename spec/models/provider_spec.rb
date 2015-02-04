require 'spec_helper'

describe Provider do

  it { should have_many :title_provider_groups }
  it { should have_many :title_provider_group_names }
  it { should have_many :search_provider_groups }
  it { should have_many :search_provider_group_names }
  it { should have_many :selected_providers_for_requests }
  it { should have_many :request_to_providers }
  it { should have_many :images }
  it { should have_many :recent_images }
  it { should have_many :provider_contacts }
  it { should have_many :authorized_countries }
  it { should have_many :countries }

  it { should validate_presence_of  :name }
  it { should validate_presence_of  :string_key }
  it { should validate_presence_of  :copyright_rule }

  it "should validates uniqueness of name" do
    provider = Provider.make
    should validate_uniqueness_of :name
  end

  it "should test logo" do
     provider = Provider.create({:name => "name", :string_key => "pr", :copyright_rule => "yes"})
     provider.logo = "bidon.png" if provider.logo.blank?
   end

  it "should not allow duplicate names with different cases" do 
    provider = Provider.make
    other_provider = Provider.make_unsaved(:name => provider.name.upcase)
    other_provider.should_not be_valid
    other_provider.errors[:name].should include "is invalid"
  end

  describe "Defined class methods" do

    it "should respond to get_from_file_name" do
      Provider.should respond_to(:get_from_file_name)
    end

    it "should respond to get_from_input_dir" do
      Provider.should respond_to(:get_from_input_dir)
    end  

    it "should respond to destroy_old_images" do
      Provider.should respond_to(:destroy_old_images)
    end

    it "should respond to export_to_csv" do
      Provider.should respond_to(:export_to_csv)
    end    
  end # describe
  
  pending "It should have more tests ! :-) (to be continued)"
  
end

