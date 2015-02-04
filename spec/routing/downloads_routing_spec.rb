require 'spec_helper'

describe DownloadsController do
  describe "routing" do
    it "recognizes and generates #index" do
      { :get => "/downloads" }.should route_to(:controller => "downloads", :action => "index")
    end

    it "recognizes and generates #has_conditions" do
      { :get => "/has_conditions" }.should route_to(:controller => "downloads", :action => "has_conditions")
    end

    it "recognizes and generates #bnf_form" do
      { :get => "/bnf_form" }.should route_to(:controller => "downloads", :action => "bnf_form")
    end

 
  end # describe
end
