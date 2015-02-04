module HomeHelper

  def build_picker(ro, co)
    out = ""
    0.step(255, 255/(ro-1.0)).each do |y|
      out += '<div class="clearboth"></div>'
      0.step(255, 255/(co-1.0)).each do |x|
        color = "\##{"%02x" % (255 -y).round}#{"%02x" % (255 -x).round()}#{"%02x" % y.round}"
        out += '<li class="color_picker" title="'+color+'" style="background-color:'+color+'"></li>'
      end
    end
    raw(out)
  end

  def rep_check(rep_string)
    Image.where(:reportage => rep_string).count
  end

end