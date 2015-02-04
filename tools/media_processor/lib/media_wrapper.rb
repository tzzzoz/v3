require 'RMagick'

module MediaWrapper

  class Image

    attr_accessor :file, :width, :height

    def width
      @file.columns
    end

    def height
      @file.rows
    end

    def initialize(path)
      @file = Magick::Image.read(path).first
    end

    def read_iptc(mapping)
      val_utf = @file.get_iptc_dataset("1:90")
      current_meta = {}
      mapping.each do |key, val|
        extracted_val = @file.get_iptc_dataset(key)
        unless extracted_val.to_s.blank?
          extracted_val.gsub!(/\s*;\s*/, ' ') if val == 'subject'
          # extracted_val = marek_decrypt(extracted_val) if (val == 'ms_picture_id' && extracted_val.to_s.length > 20)
          if val_utf.blank?
            current_meta[val.to_sym] = extracted_val.encode('utf-8', 'iso-8859-15').strip
          else
            current_meta[val.to_sym] = extracted_val.force_encoding("UTF-8").strip
          end
        end
      end
      current_meta
    end

    def fit_square(side)
      @file.resize_to_fit(side, side)
    end

  end

end
