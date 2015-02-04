module Admin::UsersHelper

  def select_table
    if @current_title
      a = []
    else
      a = [[I18n.t('admin.user.select_title'),0],[I18n.t('admin.user.select_title_null'),"orphans"]]
    end
    a += Title.order('name ASC').all.collect{|t| [t.name, t.id]}

  end

  def by_default_selected
    if params[:title_id]
      params[:title_id]
    elsif params[:orphans] == 'orphans'
      @users = User.where(title_id: nil)
      "orphans"
    else
      0
    end
  end

  def by_default_title
    @current_title
  end

  def by_default_role
    if @user.login.blank?
      "editor_user"
    else
      @user.roles.first
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