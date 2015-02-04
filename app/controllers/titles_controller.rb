class TitlesController < ApplicationController

  layout 'simple'

  def index

      @titles = Title.order("visible_name ASC").where(:visible => [1,2,3])
      unless Title.find_by_name("IconosIndependants").nil?
        title = Title.find_by_name("IconosIndependants")
        @icono_title = title.visible_name
        @icono_users = User.where("title_id = #{title.id} and phone != '000'").order(:last_name)
      end
      unless Title.find_by_name("Partenaires").nil?
        title = Title.find_by_name("Partenaires")
        @partner_title = title.visible_name
        @partner_users = User.where("title_id = #{title.id} and phone != '000'").order(:last_name)
      end

      @l_prov = []
      session[:provhd].each_index{|i| @l_prov << i if session[:provhd][i] == 1}
      unless @l_prov.count > 1
        p_id = @l_prov.first
        @prov = Provider.find_by_id(p_id).name
        @autho = {}
        @titles.each do |t|
          tpg = TitleProviderGroup.where(title_provider_group_name_id: t.title_provider_group_name_id, provider_id: p_id)
          @autho[t.id] = 0
          @autho[t.id] = Authorization.where(title_provider_group_id: tpg.first.id).count + 1 unless tpg.blank?
        end
      end

      respond_to do |format|
        format.html
        format.csv { send_data Title.export_to_csv(@titles, @icono_title, @icono_users, @partner_title, @partner_users), :filename => "titles.csv", :type => 'text/csv; charset=utf-8; header=present'}
      end

  end

end