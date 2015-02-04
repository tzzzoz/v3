module MediaWrapper
  class Pixpalace < Feed

    def process
      super do
        @current.meta[:reception_date] = date_from_marek
        valu = @current.meta[:erasable].split('@@@')[-1]
        case (valu)
          when "news"
            @current.meta[:erasable] = true
            @current.meta[:hires_location] = @current.meta[:hires_location].split('=')[-1]
          when "stock"
            @current.meta[:erasable] = false
            @current.meta[:hires_location] = @current.meta[:hires_location].split('=')[-1]
          when "video"
            @current.meta[:fonds] = 1
            if @current.provider.string_key == "akamedia"
              @current.meta[:ms_id] = "flv"
              @current.meta[:hires_location] = @current.meta[:title]
            elsif @current.provider.string_key == "Stockfood"
              @current.meta[:ms_id] = "mov"
              video_name = @current.meta[:original_filename].gsub(".jpg","_480x270.mov")
              @current.meta[:hires_location] = "images/videos/stockfood/#{video_name}"
            end
          else
            @current.meta[:fonds] = 0
            @current.meta[:erasable] = false
            @current.meta[:hires_location] = @current.meta[:hires_location].split('=')[-1]
        end
        #@current.meta[:hires_location] = @current.meta[:hires_location].split('=')[-1]
        @current.meta[:ms_picture_id] = marek_decrypt(@current.meta[:ms_picture_id])
        @current.meta[:ms_image_id] = @current.meta[:ms_picture_id].to_i
      end
      @request_serial = build_request_serial if request_response?
    end

    def write
      unless @request_serial
        seek_then_replace
      else
        save_request_reponse(@request_serial)
      end
    end

    private

    def date_from_marek
      @current.meta[:reception_date].split('@@@')[0..1].join(' ') unless @current.meta[:reception_date].blank?
    end

    def erasable?
      era = !!@current.meta[:erasable]? @current.meta[:erasable].split('@@@')[-1] : false
      era == 'news'
    end

    def build_request_serial
      serial = "#{@current.meta[:request_title]}_#{@current.meta[:request_server]}_#{@current.meta[:request_key]}"
      @current.meta.delete(:request_title)
      @current.meta.delete(:request_server)
      @current.meta.delete(:request_key)
      @current.meta[:private_image] = true
      serial
    end

    def request_response?
      true unless (
        @current.meta[:request_title].blank? ||
        @current.meta[:request_server].blank? ||
        @current.meta[:request_key].blank?
      )
    end
    
    def save_request_reponse(serial)
      LOG.debug("saving request response for #{serial}")
      request_to_prov = ::RequestToProvider.find_by_serial(serial)
      unless request_to_prov.nil?
        im_old = ::Image.find_by_ms_image_id(@current.meta[:ms_image_id])
        if im_old.nil?
          im = ::Image.new(@current.meta)
          im.save
          request_to_prov.provider_response_to_requests.create(:image_id => im[:id])
        else
          @current.meta[:private_image] = im_old[:private_image]
          @current.meta[:reception_date] = im_old[:reception_date]
          im_old.update_attributes(@current.meta)
        end
        write_files
        LOG.info("request response for #{serial} saved private = #{@current.meta[:private_image]}")
      end
      LOG.info("request response for #{serial} NOT saved")
    end

  def marek_decrypt(mastr)
    tostr = ''
    offset = 0
    scan = true
    while scan
      skipChars = mastr[offset..offset].to_i
      offset += skipChars + 1
      if mastr[offset..offset] == '0'
        if mastr[offset+1..offset+1].to_i < 5
          tostr << '/'
        else
          tostr << '@'
        end
      elsif mastr[offset..offset] == '1'
        if mastr[offset+1..offset+1].to_i < 5
          tostr << ' '
        else
          tostr << '.'
        end
      else
        tostr << mastr[offset+1..offset+1]
      end
      offset += 2
      scan = false if mastr[offset].nil?
    end
    tostr.tr("A-Za-z", "N-ZA-Mn-za-m")
  end

  end
end
