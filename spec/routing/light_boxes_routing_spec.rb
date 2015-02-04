require 'spec_helper'

describe LightBoxesController do
  describe "routing" do
    it "recognizes and generates #index" do
      { :get => "/light_boxes" }.should route_to(:controller => "light_boxes", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/light_boxes/new" }.should route_to(:controller => "light_boxes", :action => "new")
    end

    it "recognizes and generates #create" do
      { :post => "/light_boxes" }.should route_to(:controller => "light_boxes", :action => "create") 
    end

   it "recognizes and generates #show" do
      { :get => "/light_boxes/1" }.should route_to(:controller => "light_boxes", :action => "show", :id => "1")
    end
   
     it "recognizes and generates #edit" do
      { :get => "/light_boxes/1/edit" }.should route_to(:controller => "light_boxes", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/light_boxes" }.should route_to(:controller => "light_boxes", :action => "create") 
    end

    it "recognizes and generates #update" do
      { :put => "/light_boxes/1" }.should route_to(:controller => "light_boxes", :action => "update", :id => "1") 
    end

    it "recognizes and generates #destroy" do
      { :delete => "/light_boxes/1" }.should route_to(:controller => "light_boxes", :action => "destroy", :id => "1") 
    end
     
  end # describe
end
