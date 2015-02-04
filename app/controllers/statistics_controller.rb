require 'pixways'

class StatisticsController < ApplicationController
  layout "statistics"

  before_filter :load_cached_search_params, :only => [:index, :stats_to_csv]
  #before_filter :store_location, :only => [:index]

  #load_and_authorize_resource

  def index
    pays = @current_params[:pays].to_i

    if params[:per_page]
      per_page = params[:per_page]
    elsif @current_params[:per_page]
      per_page = @current_params[:per_page]
    else
      per_page = 60
    end

    unless @current_params[:search_since]
      if cookies[:stats_since].present?
        @current_params[:search_since] = cookies[:stats_since]
      else
        @current_params[:search_since] = "3_month"
      end
    end
    cookies[:stats_since] = @current_params[:search_since]

    l_prov = []
    session[:provhd].each_index{|i| l_prov << i if session[:provhd][i] == 1}
    @providers = Provider.where(:id => l_prov).order(:name)
    @pw_providers = @providers.where(:local => false)
    @local_providers = @providers.where(:local => true)

    cearch = {}

    sort = 'created_at'
    sort = @current_params[:sort] if @current_params[:sort]
    sort = "by_#{sort}"

    #cearch[:match_mode] = :extended
    cearch[:per_page] = per_page
    cearch[:page] = params[:page].to_i if params[:page]


    cearch[:conditions] = Statistic.params_to_conditions(@current_params)
    cearch[:with] = Statistic.params_to_with(@current_params, l_prov, pays)
    keywords = @current_params[:key_words] ? Pixways::SearchesHelper.filter_keywords(@current_params[:key_words]) : ''

    @statistics = Statistic.instance_eval(sort).search(keywords, cearch)
    if current_user.is_superadmin?
      facets = Statistic.facets(keywords, cearch.except(:page, :per_page) )
      @nb_stats = facets[:provider_id]
    end

    pw_titles = []
    if current_user.is_provider_admin? || current_user.is_provider_user?
      if pays == 0
        pw_titles = Title.order("name ASC").where(:visible => [1,2,3])
      else
        pw_titles = Title.order("name ASC").where(:visible => [1,2,3], :country_id => pays)
      end

    else
      if current_user.is_superadmin?
        if params[:tpgn_id]
          pw_titles = Title.order("name ASC").where(:title_provider_group_name_id => params[:tpgn_id])
        else
          pw_titles = Title.order_by_name_select_country(pays)
        end
      else
        #val_id = Title.find(current_user.title_id).title_provider_group_name_id
        if pays == 0
          pw_titles = Title.order("name ASC").where(:id => current_user.title_id, :visible => [1,2,3])
        else
          pw_titles = Title.order("name ASC").where(:id => current_user.title_id, :country_id => pays, :visible => [1,2,3])
        end

      end
    end
    @titles = pw_titles

    @image_fields = []
    @displayed_image_fields = {}
    Image.searchable_fields.each do |sf|
       @image_fields << sf.to_s
       @displayed_image_fields[sf] = @current_params[sf] if  @current_params[sf]
    end
    respond_to do|format|
      format.html { render :stream => true }
      format.js { render :stream => true }
      format.csv {send_data Statistic.export_to_csv(@statistics), :filename => "statistics_" + Time.now.strftime("%Y-%m-%d_%H-%M") + ".csv", :type => 'text/csv; charset=utf-8; header=present'}
    end

  end

  def show
    @stat = Statistic.find(params[:id])
    respond_to do |format|
     format.xml { render :xml => @stat }
    end
  end


  def create
    ms_id = Image.find(params[:statistic][:image_id].to_i).ms_image_id
    @stat =  Statistic.new(params[:statistic])
    respond_to do |f|
      if @stat.save
        MessageToMs::SendLrToPixtrakk.send(ms_id)
        f.xml  { render :xml => @stat, :status => :created, :location => @stat }
        f.json { render json: @stat }
      else
        f.xml  { render :xml => @stat.errors, :status => :unprocessable_entity }
        f.json { render json: @stat.errors }
      end
    end
  end

  def mail_downloads
    if (Server.find_by_is_self(true).name == "webAgencesV2FR2")
      users = User.all.collect{|u| u.id unless (u.roles_mask == 16 || u.roles_mask == 8 || u.roles_mask == 1)}
      #users = User.all
      time_range = (Time.now.midnight-7.day)..(Time.now.midnight)
      week_range =  "du #{I18n.l(Date.today-7.day)} au #{I18n.l(Date.today-1.day)}"
      prov_bd = {}
      prov_hd = {}
      title_hd = {}
      title_bd = {}
      hide_hd = {}
      hide_bd = {}
      total_prov_hd = 0
      total_title_hd = 0
      total_prov_bd = 0
      total_title_bd = 0
      total_hide_hd = 0
      total_hide_bd = 0

      Provider.where(:actif => true).order(:name).each do |prov|
        stats = Statistic.joins(:image).where(:user_id => users, :images => {:provider_id => prov.id}, :statistics => {:created_at => time_range}).order('created_at desc')
        statsbd = Statistic.joins(:image).where(:user_id => users, :images => {:provider_id => prov.id}, :statistics => {:created_at => time_range}, :operation_label_id => 1).count
        statshd = Statistic.joins(:image).where(:user_id => users, :images => {:provider_id => prov.id}, :statistics => {:created_at => time_range}, :operation_label_id => 2).count


        prov_hd[prov.name] = statshd
        prov_bd[prov.name] = statsbd
        total_prov_hd += statshd
        total_prov_bd += statsbd
        mel = []
        mel = ProviderContact.where(:provider_id => prov.id, :receive_stat => true).collect{|pc| pc.email}
        date_range = "#{prov.name} du #{I18n.l(Date.today-7.day)} au #{I18n.l(Date.today-1.day)}"
        UserMailer.send_stats(stats, mel, date_range, statsbd, statshd).deliver
      end
      UserMailer.pp_prov_stats(week_range, prov_hd, prov_bd, total_prov_hd, total_prov_bd).deliver
      Title.all.each do |title|
        users = User.where(:title_id => title.id).collect{|u| u.id unless (u.roles_mask == 16 || u.roles_mask == 8 || u.roles_mask == 1)}
        unless users.blank?
          t_statshd = Statistic.where(:user_id => users, :created_at => time_range, :operation_label_id => 2).count
          t_statsbd = Statistic.where(:user_id => users, :created_at => time_range, :operation_label_id => 1).count
          title_hd[title.name] = t_statshd
          title_bd[title.name] = t_statsbd
          total_title_hd += t_statshd
          total_title_bd += t_statsbd
        end
      end
      UserMailer.pp_title_stats(week_range, title_hd, title_bd, total_title_hd, total_title_bd).deliver

      Title.all.each do |title|
        users = User.where(:title_id => title.id).collect{|u| u.id if (u.roles_mask == 16 || u.roles_mask == 8 || u.roles_mask == 1)}
        unless users.blank?
          t_hidehd = Statistic.where(:user_id => users, :created_at => time_range, :operation_label_id => 2).count
          t_hidebd = Statistic.where(:user_id => users, :created_at => time_range, :operation_label_id => 1).count
          hide_hd[title.name] = t_hidehd
          hide_bd[title.name] = t_hidebd
          total_hide_hd += t_hidehd
          total_hide_bd += t_hidebd
        end
      end
      UserMailer.pp_hide_stats(week_range, hide_hd, hide_bd, total_hide_hd, total_hide_bd).deliver

      render :notice => "Email stats envoye"
    end
  end

  private


  def search_action(per_page, pays)
    cearch = {}

    sort = 'created_at'
    sort = @current_params[:sort] if @current_params[:sort]
    sort = "by_#{sort}"

    cearch[:match_mode] = :extended
    cearch[:per_page] = per_page
    cearch[:page] = params[:page].to_i if params[:page]


    cearch[:conditions] = Statistic.params_to_conditions(@current_params)
    cearch[:with] = Statistic.params_to_with(@current_params, pays)
    keywords = @current_params[:key_words] ? Pixways::SearchesHelper.filter_keywords(@current_params[:key_words]) : ''

    Statistic.instance_eval(sort).search(keywords, cearch)
  end

end
