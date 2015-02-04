module MediaWrapper
  class Pixtrakk < Feed

    def process
      super do
        @current.meta[:reception_date] = date_from_marek
        @current.meta[:erasable] = erasable?
        @current.meta[:hires_location] = @current.meta[:hires_location].split('=')[-1]
        @current.meta[:ms_picture_id] = marek_decrypt(@current.meta[:ms_picture_id])
        @current.meta[:ms_image_id] = @current.meta[:ms_picture_id].to_i
      end
    end

    def write
      pt_seek_then_replace
    end

    private

    def date_from_marek
      @current.meta[:reception_date].split('@@@')[0..1].join(' ') unless @current.meta[:reception_date].blank?
    end

    def erasable?
      era = !!@current.meta[:erasable]? @current.meta[:erasable].split('@@@')[-1] : false
      era == 'news'
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
