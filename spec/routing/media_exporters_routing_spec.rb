require 'spec_helper'

describe MediaExportersController do
  describe "routing" do
    it "recognizes and generates #index" do
      { :get => "/media_exporters" }.should route_to(:controller => "media_exporters", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/media_exporters/new" }.should route_to(:controller => "media_exporters", :action => "new")
    end

    it "recognizes and generates #create" do
      { :post => "/media_exporters" }.should route_to(:controller => "media_exporters", :action => "create") 
    end

   it "recognizes and generates #show" do
      { :get => "/media_exporters/1" }.should route_to(:controller => "media_exporters", :action => "show", :id => "1")
    end
   
     it "recognizes and generates #edit" do
      { :get => "/media_exporters/1/edit" }.should route_to(:controller => "media_exporters", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/media_exporters" }.should route_to(:controller => "media_exporters", :action => "create") 
    end

    it "recognizes and generates #update" do
      { :put => "/media_exporters/1" }.should route_to(:controller => "media_exporters", :action => "update", :id => "1") 
    end

    it "recognizes and generates #destroy" do
      { :delete => "/media_exporters/1" }.should route_to(:controller => "media_exporters", :action => "destroy", :id => "1") 
    end
     
     
  end # describe
end
