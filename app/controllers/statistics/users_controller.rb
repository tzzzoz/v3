class Statistics::UsersController < ApplicationController

  layout nil

  before_filter :load_cached_search_params, :only => [:index]

  def index

    if current_user.is_provider_admin?
      pw_users = []
      titres = []

      tpg = Authorization.where(:permission_label_id => 1, :permission_label_id => 2, :title_provider_group_id => TitleProviderGroup.where(title_provider_group_name_id: Title.find(current_user.title_id).title_provider_group_name_id) )
      tpg.each do |tpg_id|
        provider_id = TitleProviderGroup.find(tpg_id.title_provider_group_id).provider_id
        titles = TitleProviderGroup.select("title_provider_group_name_id, id").where(:provider_id => provider_id)
        titles.delete_if{|x| verify_authorization(x.id)}

        titres.concat(Title.where(:title_provider_group_name_id => titles.collect!{|x| x.title_provider_group_name_id.to_s}).all)

        titres.each do |t|
          ti = Title.find(t.id).users

          pw_users.concat(Title.find(t.id).users) unless ti.empty?

        end
      end

      @pw_users = pw_users.uniq

    else
      if current_user.is_superadmin?
        if params[:title_id]
          @pw_users = User.order("login ASC").where(:title_id => params[:title_id])
        else
          @pw_users = User.order("login ASC").all
        end
      else
        @pw_users = User.order("login ASC").where(:title_id => current_user.title_id).all
      end
    end


  end

  private

  def verify_authorization(value)
    a = Authorization.where(:permission_label_id => 1, :permission_label_id => 2, :title_provider_group_id => value)
    a.empty?

  end

end
