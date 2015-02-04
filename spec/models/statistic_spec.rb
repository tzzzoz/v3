require 'spec_helper'

describe Statistic do
  it { should belong_to :image }
  it { should belong_to :user }
  it { should belong_to :operation_label }

  it { should validate_presence_of :user_id }
  it { should validate_presence_of :image_id }
  it { should validate_presence_of :operation_label_id }

  describe "Defined class methods" do

    it "should respond to safe_save" do
      Statistic.should respond_to(:safe_save)
    end

    it "should respond to export_to_csv" do
      Statistic.should respond_to(:export_to_csv)
    end

  end # describe


  context "A new Statistic" do
    let(:statistic) { Statistic.make }

    it "should returns the image provider" do
      statistic.provider.should == statistic.image.provider
    end

    it "should returns the user title_id" do
      statistic.title_id == statistic.user.title_id
    end

    it "should return the localized created_at date" do
      statistic.localised_created_at.should ==  I18n.l(statistic.created_at.in_time_zone.to_time)
    end

    it "should return the localized updated_at date" do
      statistic.localised_updated_at.should ==  I18n.l(statistic.updated_at.in_time_zone.to_time)
    end 
   
    it "should return the localized operation label" do
      statistic.operation_label_name.should ==  I18n.t(statistic.operation_label.label.to_sym)
    end  
    
  end # context
end
