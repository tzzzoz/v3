require 'spec_helper'

describe RequestToProvider do

  it { should belong_to  :user }
  it { should have_many :provider_response_to_requests }
  it { should have_many :selected_providers_for_requests }
  it { should have_many :providers }
  it { should have_many :images }

  it { should validate_presence_of :user_id }

  describe "Defined class methods" do

    it "should respond to gen_serial" do
      RequestToProvider.should respond_to(:gen_serial)
    end

    it "should respond to send_request" do
      RequestToProvider.should respond_to(:send_request)
    end

    it "should have the title, server name and five characters in the generated serial" do
      user = User.make
      serial = RequestToProvider.gen_serial(user.id)
      serial.should match(/#{user.title.name}\_#{user.title.server.name}\_(:?\w){5}/)
    end
    
  end

  context "A new ProviderResponseToRequest" do

    let(:request_to_provider) { RequestToProvider.make }
    
    it "should have an responses_count attribute initialized to zero" do
      request_to_provider.responses_count.should == 0
    end

    it "should returns the response_count" do
      request_to_provider.response_count.should == request_to_provider.provider_response_to_requests.count
    end 


  end # context

end
