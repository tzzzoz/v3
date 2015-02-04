require 'spec_helper'

describe Country do
  it { should have_many :authorized_countries }
  it { should have_many :providers }
  it { should have_many :titles }
  it { should have_many :title_provider_group_names }
end

 