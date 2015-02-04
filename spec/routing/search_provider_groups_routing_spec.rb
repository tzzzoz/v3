require 'spec_helper'

describe SearchProviderGroupsController do
  describe "routing" do
  
  it "recognizes and generates #index" do
      { :get => "/search_provider_groups" }.should route_to(:controller => "search_provider_groups", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/search_provider_groups/new" }.should route_to(:controller => "search_provider_groups", :action => "new")
    end

    it "recognizes and generates #create" do
      { :post => "/search_provider_groups" }.should route_to(:controller => "search_provider_groups", :action => "create") 
    end

   it "recognizes and generates #show" do
      { :get => "/search_provider_groups/1" }.should route_to(:controller => "search_provider_groups", :action => "show", :id => "1")
    end
   
     it "recognizes and generates #edit" do
      { :get => "/search_provider_groups/1/edit" }.should route_to(:controller => "search_provider_groups", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/search_provider_groups" }.should route_to(:controller => "search_provider_groups", :action => "create") 
    end

    it "recognizes and generates #update" do
      { :put => "/search_provider_groups/1" }.should route_to(:controller => "search_provider_groups", :action => "update", :id => "1") 
    end

    it "recognizes and generates #destroy" do
      { :delete => "/search_provider_groups/1" }.should route_to(:controller => "search_provider_groups", :action => "destroy", :id => "1") 
    end
    
  end # describe
end



