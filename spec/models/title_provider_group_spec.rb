require 'spec_helper'

describe TitleProviderGroup do
  
  it { should validate_presence_of :provider_id }
  it { should validate_presence_of :title_provider_group_name_id }


  let(:title_provider_group_name) { TitleProviderGroupName.make }
  let(:provider) { Provider.make }

  it "should not allow duplicate provider_id for the same TitleProviderGroupName" do
    tpg_one = TitleProviderGroup.make(:provider_id => provider, :title_provider_group_name => title_provider_group_name)
    tpg_two = TitleProviderGroup.make_unsaved(:provider_id => provider, :title_provider_group_name => title_provider_group_name)
    tpg_two.should_not be_valid
    tpg_two.errors[:provider_id].should include "has already been taken"
  end

  it "should allow duplicate provider_id for different TitleProviderGroupName" do
    tpg_one = TitleProviderGroup.make(:provider_id => provider, :title_provider_group_name => title_provider_group_name)
    tpg_two = TitleProviderGroup.make(:provider_id => provider, :title_provider_group_name => TitleProviderGroupName.make)
    tpg_two.should be_valid
  end

  pending 'when creating a permission label' do
    let(:permission_label) { PermissionLabel.make(:label => 'wazaa') }
    let(:title_provider_group) { TitleProviderGroup.make }

    it 'should respond false to the new label' do
      title_provider_group.wazaa.should be_false
    end
    it 'should be a check_box boolean setter' do
      title_provider_group.wazaa = '1'
      title_provider_group.wazaa.should be_true
    end
  end

  pending "to be continued ..."

end