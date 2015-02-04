module Admin::TitlesHelper

  def tpgn_name(value)
    if value == nil
      raw "<span class='pw_orphans'>#{I18n.t('admin.title.orphans')}</span>"
    else
      TitleProviderGroupName.find(value).name
    end

  end

  def select_table_group
    g = [[I18n.t('admin.tpgn.select_group'),0]]
    g += TitleProviderGroupName.order(:name).collect{|t| [ t.name, t.id ]}

  end

  def by_default_selected_group
    if params[:tpgn_id]
      params[:tpgn_id]
    else
      0
    end
  end

end

