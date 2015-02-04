require 'spec_helper'

describe RequestToProvidersController do
  describe "routing" do
    it "recognizes and generates #index" do
      { :get => "/request_to_providers" }.should route_to(:controller => "request_to_providers", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/request_to_providers/new" }.should route_to(:controller => "request_to_providers", :action => "new")
    end

    it "recognizes and generates #create" do
      { :post => "/request_to_providers" }.should route_to(:controller => "request_to_providers", :action => "create") 
    end

   it "recognizes and generates #show" do
      { :get => "/request_to_providers/1" }.should route_to(:controller => "request_to_providers", :action => "show", :id => "1")
    end
   
     it "recognizes and generates #edit" do
      { :get => "/request_to_providers/1/edit" }.should route_to(:controller => "request_to_providers", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/request_to_providers" }.should route_to(:controller => "request_to_providers", :action => "create") 
    end

    it "recognizes and generates #update" do
      { :put => "/request_to_providers/1" }.should route_to(:controller => "request_to_providers", :action => "update", :id => "1") 
    end

    it "recognizes and generates #destroy" do
      { :delete => "/request_to_providers/1" }.should route_to(:controller => "request_to_providers", :action => "destroy", :id => "1") 
    end
         
  end # describe
end
