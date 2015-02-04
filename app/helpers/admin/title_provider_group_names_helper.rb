module Admin::TitleProviderGroupNamesHelper

  def select_country
    p = [[I18n.t('admin.tpgn.select_country'),0]]
    p += Country.all.collect {|c| [ c.name, c.id ] }

  end

  def default_country
    if @country_id
      @country_id
    else
      0
    end
  end

  def select_group
    g = [[I18n.t('admin.tpgn.select_group'),0]]
    g += @title_provider_group_names.collect {|t| [ t.name, t.id ]}

  end

  def default_group
    if @title_provider_group_name_id
      @title_provider_group_name_id
    else
      0
    end
  end

end