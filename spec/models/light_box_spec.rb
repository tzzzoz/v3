require 'spec_helper'

describe LightBox do
  it { should belong_to   :user }
  it { should have_many   :light_box_images }
  it { should have_many   :images }

  it { should validate_presence_of :name }
  it { should validate_presence_of :user_id }
  it { should validate_presence_of :title_id }


  let(:user) { User.make }
  let(:title) { Title.make }


  it "should not allow duplicate names for the same user" do
    lightbox_one = LightBox.make(:name => "My lightbox", :user => user, :title => title )
    lightbox_two = LightBox.make_unsaved(:name => "My lightbox", :user => user, :title => title)
    lightbox_two.should_not be_valid
    #lightbox_two.errors[:name].should include "has already been taken"
  end

  it "should not allow duplicate names with different cases for the same user" do
    lightbox_one = LightBox.make(:name => "MY LIGHTBOX", :user => user, :title => title)
    lightbox_two = LightBox.make_unsaved(:name => "My lightbox", :user => user, :title => title)
    lightbox_two.should_not be_valid
    #lightbox_two.errors[:name].should include "has already been taken"
  end

  it "should allow duplicate names for different user" do
    other_user = User.make
    lightbox_one = LightBox.make(:name => "My lightbox", :user => user, :title => title)
    lightbox_two = LightBox.make(:name => "My lightbox", :user => other_user, :title => title)
    lightbox_two.should be_valid
  end

  context "A new LightBox" do
    let(:lightbox) { LightBox.make }

    it "should not be shared" do
      lightbox.should_not be_shared
    end

    it "should be shared readable" do
      lightbox.readable!
      lightbox.should be_readable
    end

    it "should be shared writable" do
      lightbox.writable!
      lightbox.should be_writable
    end

    it "should have a generated hash code" do
      lightbox.hash_code.should_not be nil
    end

    it "should have an items_count attribute initialized to zero" do
      lightbox.items_count.should == 0
    end

    it "should add images by ids" do
      images = [{:image_id => Image.make.id}, {:image_id => Image.make.id}, {:image_id => Image.make.id}]
      lightbox.light_box_images.create(images)
      lightbox.images.count.should == images.count
    end

    it "should return images ordered by reversed insertion order with the right scope" do
      images = [Image.make, Image.make, Image.make]
      lightbox.light_box_images.create(images.collect{|i| {:image_id => i.id }})
      lightbox.images.order_by_light_box_image_id_desc.reverse.should == images
    end

  end # context

  context "A new readable LightBox" do
    let(:lb_readable) { LightBox.make(:r) }

    it "should be readable" do
      lb_readable.should be_readable
    end

  end # context


  context "A new writable LightBox" do
    let(:lb_writable) { LightBox.make(:rw) }

    it "should be readable" do
      lb_writable.should be_writable
    end
  end # context
  
end
