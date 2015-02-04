require 'spec_helper'

describe HomeController do
  describe "routing" do
    it "recognizes and generates #index" do
      { :get => "/home" }.should route_to(:controller => "home", :action => "index")
    end

    it "recognizes and generates #show_light_boxe" do
      { :get => "/home/show_light_boxe" }.should route_to(:controller => "home", :action => "show_light_boxe")
    end

  end # describe
end
