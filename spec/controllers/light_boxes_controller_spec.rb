require 'spec_helper'

describe LightBoxesController do
  
    context "When the user is not authenticated" do
    it "should fail to access protected area" do
      get :index
      response.should_not be_success 
    end

    it "should redirect to login page" do
      get :index
      response.should be_redirect
      response.location.should match %r[/user_session/new$]
    end
  end

  context "When the user is authenticated" do
    before(:each) do
      activate_authlogic
      @current_user = UserSession.create(User.make).user
    end

    it "should access protected area" do
      get :index, :format => :js
      response.should be_success 
    end
  end


end

