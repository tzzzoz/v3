require 'spec_helper'

describe OperationLabel do
  it { should have_many :statistics}
  
    it "should validates uniqueness of label" do
    operation_label = OperationLabel.make
    should validate_uniqueness_of :label
  end
end
