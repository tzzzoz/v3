require 'spec_helper'

describe MediasController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/medias" }.should route_to(:controller => "medias", :action => "index")
    end

  end # describe
end
