require 'spec_helper'

describe SearchProviderGroup do
  it { should belong_to :provider }
  it { should belong_to :search_provider_group_name }
  
  it { should validate_presence_of :provider }
  #it { should validate_presence_of :search_provider_group_name }
end
