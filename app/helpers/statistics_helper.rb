module StatisticsHelper


  def select_stats_table
    a = [[I18n.t('admin.user.select_title'),0]]
    a += Title.all.collect{|t| [t.name, t.id]}

  end

  def by_default_selected
    if params[:title_id]
      params[:title_id]
    else
      0
    end
  end

  def country_by_name
    Country.order(:name)
  end


end
