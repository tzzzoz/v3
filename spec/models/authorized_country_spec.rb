require 'spec_helper'

describe AuthorizedCountry do
  it { should validate_presence_of :country_id }
  it { should validate_presence_of :provider_id }
end
