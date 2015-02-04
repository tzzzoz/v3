module ReportagesHelper

  def prov_id_find(sk)
    return Provider.find_by_string_key(sk).id
  end

  def img_find(ms_id)
    return Image.find_by_ms_image_id(ms_id).thumb_location
  end

  def img_id_find(ms_id)
    return Image.find_by_ms_image_id(ms_id).id unless Image.where(:ms_image_id => ms_id).first.nil?
    nil
  end

  def img_ratio_find(ms_id)
    return Image.find_by_ms_image_id(ms_id).ratio
  end

  def sortable(column, title = nil)
    title ||= column.titleize
    css_class = column == sort_column ? "current #{sort_direction}" : nil
    direction = column == sort_column && sort_direction == "asc" ? "desc" : "asc"
    link_to title, {:sort => column, :direction => direction, :keyword => params[:keyword],:panier => params[:panier],:liste_providers => params[:liste_providers],:offres_reportages => params[:offres_reportages]}, {:class => css_class}
  end

end