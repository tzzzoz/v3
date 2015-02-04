require 'spec_helper'

describe UserSessionsController do
  describe "routing" do


    it "recognizes and generates #new" do
      { :get => "/user_session/new" }.should route_to(:controller => "user_sessions", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/user_session" }.should route_to(:controller => "user_sessions", :action => "show")
    end

    it "recognizes and generates #edit" do
      { :get => "/user_session/edit" }.should route_to(:controller => "user_sessions", :action => "edit")
    end

    it "recognizes and generates #create" do
      { :post => "/user_session" }.should route_to(:controller => "user_sessions", :action => "create") 
    end

    it "recognizes and generates #update" do
      { :put => "/user_session" }.should route_to(:controller => "user_sessions", :action => "update") 
    end

    it "recognizes and generates #destroy" do
      { :delete => "/user_session" }.should route_to(:controller => "user_sessions", :action => "destroy") 
    end

    it "recognizes and generates #change_language" do
      { :get => "/change_language" }.should route_to(:controller => "user_sessions", :action => "change_language")
    end

    it "recognizes and generates #login" do
      { :get => "/login" }.should route_to(:controller => "user_sessions", :action => "create")
    end

    it "recognizes and generates #logout" do
      { :get => "/logout" }.should route_to(:controller => "user_sessions", :action => "destroy")
    end

    it "recognizes and generates #error" do
      { :get => "/error" }.should route_to(:controller => "user_sessions", :action => "error")
    end

    it "recognizes and generates #denied" do
      { :get => "/denied" }.should route_to(:controller => "user_sessions", :action => "denied")
    end


  end # describe
end


