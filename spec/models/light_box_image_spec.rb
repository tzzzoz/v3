require 'spec_helper'

describe LightBoxImage do
  it { should belong_to :image  }
  it { should belong_to :light_box }

  #it { should validate_presence_of :light_box_id  }

  let(:image)       { Image.make }
  let(:other_image) { Image.make }
  let(:lightbox)    { LightBox.make }

  before(:each) { LightBoxImage.destroy_all }

  it "should not allow duplicate lightbox_id for the same image" do
    lightbox_image_one = LightBoxImage.make(:light_box => lightbox, :image => image)
    lightbox_image_two = LightBoxImage.make_unsaved(:light_box => lightbox, :image => image)
    lightbox_image_two.should_not be_valid
    lightbox_image_two.errors[:light_box_id].should include "has already been taken"
  end

  it "should allow duplicate lightbox_id for different image" do
    lightbox_image_one = LightBoxImage.make(:light_box => lightbox, :image => image)
    lightbox_image_two = LightBoxImage.make_unsaved(:light_box => lightbox, :image => other_image)
    lightbox_image_two.should be_valid
  end


  context "A new LightBoxImage" do
    it "should have an items_count attribute initialized to zero" do
      lightbox.items_count.should == 0
    end
  end # context

end