module Statistics::UsersHelper

  def select_stats_users_table
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


  def title_nil(value)
    if value == nil
      "- "+I18n.t('admin.user.orphans')
    end
  end

  def title_name(value)
    if value == nil
      I18n.t('admin.user.orphans')
    else
      Title.find(value).name
    end

  end




end