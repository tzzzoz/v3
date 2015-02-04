require 'spec_helper'

describe SavedSearchesController do
  describe "routing" do
  
  it "recognizes and generates #index" do
      { :get => "/saved_searches" }.should route_to(:controller => "saved_searches", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/saved_searches/new" }.should route_to(:controller => "saved_searches", :action => "new")
    end

    it "recognizes and generates #create" do
      { :post => "/saved_searches" }.should route_to(:controller => "saved_searches", :action => "create") 
    end

   it "recognizes and generates #show" do
      { :get => "/saved_searches/1" }.should route_to(:controller => "saved_searches", :action => "show", :id => "1")
    end
   
     it "recognizes and generates #edit" do
      { :get => "/saved_searches/1/edit" }.should route_to(:controller => "saved_searches", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/saved_searches" }.should route_to(:controller => "saved_searches", :action => "create") 
    end

    it "recognizes and generates #update" do
      { :put => "/saved_searches/1" }.should route_to(:controller => "saved_searches", :action => "update", :id => "1") 
    end

    it "recognizes and generates #destroy" do
      { :delete => "/saved_searches/1" }.should route_to(:controller => "saved_searches", :action => "destroy", :id => "1") 
    end
    
  end # describe
end



