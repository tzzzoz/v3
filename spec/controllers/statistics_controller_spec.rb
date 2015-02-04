require 'spec_helper'

describe StatisticsController do

  describe "GET 'index'" do
    context "When the user is not authenticated" do
      it "should not access protected area" do
        get :index
        response.should_not be_success 
      end

      it "should be redirected to login page" do
        get :index
        response.should be_redirect
        response.location.should match %r[/user_session/new$]
      end
    end

  end

end
