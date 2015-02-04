module Statistics::TitlesHelper

  def select_stats_titles_table
    g = [[I18n.t('admin.tpgn.select_group'),0]]
    g += TitleProviderGroupName.all.collect {|tpgn| [ tpgn.name, tpgn.id ] }

  end

  def by_default_selected_group
    if params[:tpgn_id]
      params[:tpgn_id]
    else
      0
    end
  end


  def select_stats_countries_table
    c = [[I18n.t('admin.tpgn.select_country'),0]]
    c += Country.all.collect {|cou| [ cou.name, cou.id ] }

  end

  def by_default_selected_country
    if params[:country_id]
      params[:country_id]
    else
      0
    end
  end



end

