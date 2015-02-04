require 'spec_helper'

describe SelectedProvidersForRequest do

  it { should belong_to :provider }
  it { should belong_to :request_to_provider }
  
  it { should validate_presence_of :provider_id }
  it { should validate_presence_of :request_to_provider_id }
end
