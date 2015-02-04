require 'spec_helper'

describe NetMessage do
  it { should belong_to :server }
  it { should validate_presence_of :server_id }
end
