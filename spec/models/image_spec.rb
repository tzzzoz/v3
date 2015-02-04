require 'spec_helper'

describe Image do

  it { should have_many :provider_response_to_requests }
  it { should have_many :light_box_images }
  it { should have_many :light_boxes}
  it { should have_many :statistics }
  it { should belong_to :provider }

  it { should validate_presence_of :provider_id }
 
  describe "Defined class methods" do
    
    it "should respond to searchable_fields" do
      Image.should respond_to(:searchable_fields)
    end

    it "should returns the list of searchable fields" do
      fields = [:title, :subject, :instructions, :creator, :city,
      :state, :country, :headline, :credit, :source, :file_name,
      :description, :reportage, :normalized_credit, :max_avail_width, :max_avail_height,
      :original_filename, :provider_comment, :restrictions, :rights, :category,
      :supplemental_category, :urgency, :authors_position, :transmission_reference, :caption_writer]
      
      Image.searchable_fields.sort.should == fields.sort
    end
    
    it "should respond_to params_to_conditions" do
      Image.should respond_to(:params_to_conditions)
    end

    it "should respond_to params_to_with" do
      Image.should respond_to(:params_to_with)
    end

    it "should respond_to export_to_csv" do
      Image.should respond_to(:export_to_csv)
    end
  
    it "should respond_to since_conditions" do
      Image.should respond_to(:since_conditions)
    end
    
     it "should respond_to add_downloads_stats" do
      Image.should respond_to(:add_downloads_stats)
    end
    
  end # context
  
  context "A new Image" do
      let(:image) { Image.make }
      
    it "should have a provider" do
      image.provider.should_not be nil
    end
    
    it "should return the provider logo" do
      image.provider_logo.should ==  "#{PICTURES_PATH}#{image.provider.logo}"
    end
       
     it "should returns the provider name" do
      image.provider_name.should == image.provider.name
    end
    
    it "should returns the provider conditions" do
      image.provider_conditions.should == image.provider.provider_conditions
    end 
     
    it "should return the localized reception date" do
      image.localised_reception_date.should ==  I18n.l(image.reception_date.in_time_zone.to_time)
    end
    
    it "should return nil if the reception date is blank" do
      image = Image.make(:reception_date => "")
      image.localised_reception_date.should be nil
    end
    
     it "should return the localized creation date" do
      image.localised_date_created.should ==  I18n.l(image.date_created.in_time_zone.to_time)
    end
    
    it "should return nil if the creation date is blank" do
      image = Image.make(:date_created => "")
      image.localised_date_created.should be nil
    end
    
    it "should returns the thumb image location" do
     silence_warnings { RSS_IMAGE_FORMAT = :thumb }
      image.rss_image_location.should == image.thumb_location
    end
    
    it "should returns the medium image location" do
      silence_warnings { RSS_IMAGE_FORMAT = :medium }
      image.rss_image_location.should == image.medium_location
    end

  end # context
end
