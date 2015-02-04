module AdmAgencyHelper


  def nb_img(value, prov)
    if value == nil
      0
    else
      imgs = []
      nb = 0
      imgs = ProviderResponseToRequest.where(:request_to_provider_id => value).collect{|resp| resp.image_id}
      imgs.each do |i|
        im = Image.find(i)
        nb += 1 unless prov.index(im.provider_id).nil?
      end
      nb
    end

  end


end
