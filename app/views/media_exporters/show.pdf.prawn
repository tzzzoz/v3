
pdf.text @lightbox_name, :at => [ pdf.bounds.left, pdf.bounds.top]
i, j = pdf.bounds.left, pdf.bounds.top - 5 
my_y = pdf.y
@medias.each do |media|
    location = "#{RAILS_ROOT}/public#{media.send(@location)}"
    img = Prawn::Images::JPG.new(File.open(location, "rb") { |f| f.read })
    img_width, img_height  = @image_size + 5, @image_size + 5
    max_dim = img.width > img.height ? :width : :height
    pdf.image location, max_dim.to_sym => @image_size, :at => [i, j], :position => :center
    pdf.bounding_box [i, j - img_height], :width => @image_size do
        pdf.text credit(media, @credit), :size => 9
        my_y = pdf.y
    end
    if (pdf.bounds.right - (i + img_width)) > (img_width + pdf.margins[:right])
        i += img_width
    else
        i, j = pdf.bounds.left, j - (img_height)
        j = my_y - 50 if @credit != "1"
    end
    if (j - img_height - pdf.margins[:bottom]) < (pdf.bounds.bottom) && media != @medias.last
            pdf.start_new_page
            i, j = pdf.bounds.left, pdf.bounds.top - 10
    end
end
 

