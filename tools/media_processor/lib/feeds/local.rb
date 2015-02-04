module MediaWrapper
  class Local < Feed

    def process
      super do
        base_name = File.basename(@current.path)
        @current.meta[:reception_date] =  File.ctime(@current.path).utc.strftime("%Y%m%d %H:%M:%S")
        @current.meta[:erasable] = false
        @current.meta[:hires_location] = "/images/photos/#{@current.provider.string_key}/#{@current.meta[:reception_date].split(' ')[0]}/hires/#{base_name}"
        @current.meta[:max_avail_width] = @current.media.width
        @current.meta[:max_avail_height] = @current.media.height
        @current.meta[:original_filename] = base_name
        @current.meta[:ms_id] = Server.find_by_is_self(true).name
        @current.meta[:ms_image_id] = Time.now.strftime("%s%1N")
      end
    end


    def write
      local_seek_then_replace
    end

  end
end
