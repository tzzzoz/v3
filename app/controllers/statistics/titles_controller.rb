class Statistics::TitlesController < ApplicationController

  layout nil

  before_filter :load_cached_search_params, :only => [:index]

  def index

    pw_titles = []
    if current_user.is_provider_admin?

      tpg = Authorization.where(:permission_label_id => 1, :permission_label_id => 2, :title_provider_group_id => TitleProviderGroup.where(title_provider_group_name_id: Title.find(current_user.title_id).title_provider_group_name_id) )
      if params[:country_id]
        tpg.each do |tpg_id|
          provider_id = TitleProviderGroup.find(tpg_id.title_provider_group_id).provider_id

          #titles = TitleProviderGroup.select("title_provider_group_name_id, id").where(:provider_id => provider_id)
          #titles.delete_if{|x| verify_authorization(x.id)}

          titles = Title.all.collect{|t| t.id}
          pw_titles.concat(Title.order("name ASC").where(:country_id => params[:country_id]).all)
        end

      else
        tpg.each do |tpg_id|
          provider_id = TitleProviderGroup.find(tpg_id.title_provider_group_id).provider_id
          #titles = TitleProviderGroup.select("title_provider_group_name_id, id").where(:provider_id => provider_id)
          #titles.delete_if{|x| verify_authorization(x.id)}

          titles = Title.all.collect{|t| t.id}
          pw_titles.concat(Title.order("name ASC").all)
        end

      end

      @pw_titles = pw_titles.uniq

    else
      if current_user.is_superadmin?
        if params[:country_id]
          @pw_titles = Title.order("name ASC").where(:country_id => params[:country_id]).all
        elsif params[:tpgn_id]
          @pw_titles = Title.order("name ASC").where(:title_provider_group_name_id => params[:tpgn_id]).all
        else
          @pw_titles = Title.order("name ASC").all
        end
      else
        val_id = Title.find(current_user.title_id).title_provider_group_name_id
        if params[:country_id]
          @pw_titles = Title.order("name ASC").where(:id => current_user.title_id, :country_id => params[:country_id]).all
        else
          @pw_titles = Title.order("name ASC").where(:id => current_user.title_id).all
        end

      end
    end


  end


  private

  def verify_authorization(value)
    a = Authorization.where(:permission_label_id => 1, :permission_label_id => 2, :title_provider_group_id => value)
    a.empty?

  end

end
