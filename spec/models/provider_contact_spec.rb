require 'spec_helper'

describe ProviderContact do
  it { should belong_to :provider }

  it 'should validate presence of provider_id on update' do
    provider = ProviderContact.make
    prov_attrs = provider.attributes
    prov_attrs.merge!("provider_id" => '')
    provider.update_attributes(prov_attrs).should == false
  end

  it 'should not validate presence of provider_id on create' do
    provider = ProviderContact.make_unsaved(:provider_id => nil)
    provider.should be_valid
  end

  it "should validate format of email if email is set" do
    provider = ProviderContact.make_unsaved(:email => 'BAD')
    provider.should_not be_valid
    provider.errors[:email].should include "is invalid"
  end
  
    it "should not validate format of email if email is not set" do
    provider = ProviderContact.make(:email => nil)
    provider.should be_valid
  end
end
