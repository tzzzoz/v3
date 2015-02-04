require 'spec_helper'

describe Setting do
  it { should belong_to :user }
  it { should validate_presence_of :user_id }
  
  context "A new Setting" do
     it "should serialize display_params" do
      setting = Setting.make(:display_params => {:horizontal => true, :key_words => "Megan Fox" })
      setting.display_params.keys.size.should == 2
      setting.display_params.keys.should == [:horizontal, :key_words]
      setting.display_params[:horizontal].should be true
      setting.display_params[:key_words].should == "Megan Fox"
    end  
      
    it "should serialize border_color_provider" do
      setting = Setting.make(:border_color_provider => { 1 => "#fff", 2 => "#000"})
      setting.border_color_provider.keys.size.should == 2
      setting.border_color_provider.keys.should == [1, 2]
      setting.border_color_provider[1].should == "#fff"
      setting.border_color_provider[2].should == "#000"
    end  
  end # context
  
end
