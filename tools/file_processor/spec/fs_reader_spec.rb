require File.join(File.dirname(__FILE__), '..', 'lib', 'file_processor.rb')

describe FsReader do
  # Sami's first test ! :-)
  it "1+1 should equal 2" do
    res = 1+1
    res.should be 2
  end

  context "a new fs_reader initialized with a path" do
    my_path = File.join(File.dirname(__FILE__), "pics")
    fs_reader = FsReader.new(my_path)
    
    it "should have a valid path" do
      File.directory?(my_path).should be_true
    end
    
    it "should have #{my_path} in pathes" do
      fs_reader.pathes.should include(my_path)
    end

    it "should respond to each" do
      fs_reader.should respond_to(:each)
    end
    
    it "should return all the JPG pictures" do
      pics_ary =  Dir[File.join(my_path, '*')] # grab all the files in my_path
      total_jpeg = pics_ary.select { |f| f =~ /\.(jpg|jpeg|jpe)$/i } # uses only JPEG files
      res = []
      fs_reader.each { |p| res << p }
      res.count.should == total_jpeg.size
    end
    
  end

end