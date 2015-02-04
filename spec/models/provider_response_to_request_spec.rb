require 'spec_helper'

describe ProviderResponseToRequest do
  it { should belong_to :request_to_provider }
  it { should belong_to :image }

 it { should validate_presence_of :image_id }
 it { should validate_presence_of :request_to_provider_id }
  
  it "should order results by updated_at DESC" do
    first = ProviderResponseToRequest.make(:updated_at => 1.hour.ago)
    last  = ProviderResponseToRequest.make
    results = ProviderResponseToRequest.all
    results.first.id.should == last.id
    results.last.id.should == first.id
  end
  
end

