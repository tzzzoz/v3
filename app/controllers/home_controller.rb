require 'pixways'
require "json"

class HomeController < ApplicationController

  #before_filter :store_location, :only => [:index]
  before_filter :load_cached_search_params, :only => [:index, :feed]
  skip_before_filter :login_required, :only => [:feed, :show_light_boxe]
  before_filter :feed_basic_authentication, :only => [:feed, :show_light_boxe]


  def index

    val_def_ppage = @current_params["default_per_page"].to_i
    val_def_since = @current_params["search_since"]
    val_def_sort = @current_params["sort"]
    
    @show_facet = 1

    unless @current_params[:media_typ]
      if cookies[:typ_media].present?
        @current_params[:media_typ] = cookies[:typ_media]
      else
        @current_params[:media_typ] = "all"
      end
    end
    cookies[:typ_media] = @current_params[:media_typ]
    u = current_user
    if val_def_ppage == 0
      if u.setting.default_per_page == 0
        val_def_ppage = 20
        u.setting.update_attribute(:default_per_page, val_def_ppage)
      else
        val_def_ppage = u.setting.default_per_page
        @current_params["search_since"] = '1_day'
        @show_facet = 0
        u.setting.default_since = 'All'
        if val_def_sort.blank?
          if u.setting.default_sort.blank?
            @current_params["sort"] = 'reception_date'
          else
            @current_params["sort"] = u.setting.default_sort
          end
        end
      end
    else
      u.setting.update_attribute(:default_per_page, val_def_ppage) unless u.setting.default_per_page == val_def_ppage
      u.setting.update_attribute(:default_since, val_def_since) unless u.setting.default_since == val_def_since
      u.setting.update_attribute(:default_sort, val_def_sort) unless u.setting.default_sort == val_def_sort
    end

    @providers = Provider.where(:id => session[:provs]).order(:name)

    @pw_providers = @providers.where(:local => false)
    @local_providers = @providers.where(:local => true)

    @t_entries = 0

    @displayed_image_fields = {}
    @image_fields = [:title, :headline, :source, :file_name,
      :description, :reportage, :normalized_credit, :original_filename, :rights, :category]
    @image_fields.each do |sf|
       @displayed_image_fields[sf] = @current_params[sf] if @current_params[sf]
    end

    if params[:request_to_provider_id]
#      clic_save(9,u.id,4)
      rtp = RequestToProvider.find(params[:request_to_provider_id])
      @medias = rtp.images.page(1).per(rtp.responses_count)
      @t_entries = @medias.total_count
      @show_facet = 0
    else
#      clic_save(0,u.id,0)
      cearch = {}
      sort = 'reception_date'
      sort = @current_params["sort"] if @current_params["sort"]
      sort = "by_#{sort}"

      cearch[:per_page] = val_def_ppage
      cearch[:per_page] = @current_params["per_page"].to_i if @current_params["per_page"]
      cearch[:page] = params["page"].to_i if params["page"] && params["page"].to_i > 0
      cearch[:conditions] = Image.params_to_conditions(@current_params)
      cearch[:with] = Image.params_to_with(@current_params)
      cearch[:retry_stale] = true

      keywords = @current_params["key_words"] ? Pixways::SearchesHelper.filter_keywords(@current_params["key_words"]) : ''
      cearch[:excerpts] = {:limit => 1024}
      @medias = Image.instance_eval(sort).search(keywords, cearch)

      unless @show_facet == 0
        @medias.context[:panes] << ThinkingSphinx::Panes::ExcerptsPane
        @t_entries = @medias.total_entries
        @nb_images = {}
        facets = Image.facets(keywords, cearch.except(:page, :per_page))
        @nb_images = facets[:provider_id]
        unless params[:page] || @current_params["key_words"].blank? || u.is_superadmin?
          iptc_field = {}
          s_stat = SearchStat.create(:keyword => @current_params["key_words"], :since => val_def_since, :tri => val_def_sort, :date_pp_from => @current_params["reception_date_begin"], :date_pp_to => @current_params["reception_date_end"], :date_photo_from => @current_params["date_created_begin"], :date_photo_to => @current_params["date_created_end"], :format => @current_params["ratio"], :result => @t_entries, :user_id => u.id)
          [:subject, :creator, :city, :country].each do |ipf|
            iptc_field[ipf] = @current_params[ipf] unless @current_params[ipf].blank?
          end
          s_stat.search_image_fields.create(:iptc => iptc_field) unless iptc_field.empty?
          provs = {}
          if @current_params["providers"].blank?
            @pw_providers.each do |p|
              provs[p.id] = @nb_images[p.id].nil? ? 0 : @nb_images[p.id]
            end
          else
            @pw_providers.each do |p|
              if @current_params["providers"]["#{p.id}"] == '1'
                provs[p.id] = @nb_images[p.id].nil? ? 0 : @nb_images[p.id]
              end
            end
          end
          s_stat.provider_for_search_stats.create(:provs => provs)
        end
      end

      # PP2 results
      unless @current_params["key_words"].blank? || @current_params["media_typ"] == "videos"
        if params[:page] && @current_params[:ppp_res].to_i > 0
          @ppp_res = @current_params[:ppp_res].to_i
        else
          provs_key = ""
          unless @current_params["providers"].blank?
           @pw_providers.each do |p|
            if @current_params["providers"]["#{p.id}"] == '1'
              provs_key += "#{p.string_key},"
            end
           end
           provs_key.chomp!(",")
          end
          @provs = provs_key

          url_key = 'results_pp'
          #secret_key = 'secret'
          endpoint_url = "http://2.pixpalace.com"

          message = {}
          message["message_id"] = 1
          message["keyw"] = @current_params["key_words"]
          message["provs"] = provs_key
          message["ratio"] = @current_params["ratio"]
          json_message = message.to_json
          #json_authorization = Digest::MD5.hexdigest(json_message+secret_key)

          url = "#{endpoint_url}/#{url_key}"
          uri = URI(url)
          req = Net::HTTP::Post.new(uri.path)
          req.body = json_message
          req.content_type = "application/json"
          #req['Authorization'] = json_authorization

          res = Net::HTTP.start(uri.hostname, uri.port) do |http|
              http.request(req)
          end
          data = JSON.parse(res.body)
          @ppp_res = data["result"].to_i
        end
      end
    end
    @idisp = u.setting.display_params['display_text'].to_i
    @ivis = u.setting.display_params['previsualisation'].to_i
    @reload = (u.setting.reload_pref)*60 unless u.setting.reload_pref == 0
    @perpage = val_def_ppage
    @loginppp = marek_crypt(u.login)
    @notitle = 0
    @notitle = 1 if u.title_id == 23 || u.title_id == 24 || u.title_id == 26
    # @nbafp = Statistic.joins(:image).where('statistics.created_at > ? and images.provider_id = ?',"#{Time.new.strftime('%Y-%m')}-01 00:00",Provider.find_by_string_key('LocalAfp').id).count
    # render :controller=>"light_boxes", :action => "index"
    render :stream => true
  end

  def show_light_boxe
    @light_boxes=LightBox.find_by_hash_code(params[:id])
    if current_user && @light_boxes
#      clic_save(0,current_user.id,1)
      redirect_to(full_screen_light_box_path(@light_boxes.id))
    else
      render "erreur_lb", :layout => "simple"
    end
  end

  def feed
    @saved_search = current_user.saved_searches.find(params[:saved_search_id])
    @medias =   search_action(RSS_PER_PAGE)

    # Update query last search date
    @saved_search.update_attribute(:date_last_search, Time.now)
#    clic_save(0,current_user.id,2)

    respond_to do |format|
      format.rss { render :layout => nil }
    end
  end

  private

  def search_action(per_page)
    cearch = {}

    sort = 'reception_date'
    sort = @current_params["sort"] if @current_params["sort"]
    sort = "by_#{sort}"

    cearch[:per_page] = per_page
    cearch[:per_page] = @current_params["per_page"].to_i if @current_params["per_page"]
    cearch[:page] = params["page"].to_i if params["page"]
    cearch[:conditions] = Image.params_to_conditions(@current_params)
    cearch[:with] = Image.params_to_with(@current_params)
    #cearch[:retry_stale] = true

    keywords = @current_params["key_words"] ? Pixways::SearchesHelper.filter_keywords(@current_params["key_words"]) : ''
    cearch[:match_mode] = :extended
    cearch[:excerpt_options] = {:limit => 2048}
    Image.instance_eval(sort).search(keywords, cearch)
  end

  def feed_basic_authentication
    # Ask for basic auth only if user is not already logged_in (external RSS readers or first click on an RSS item)
    unless current_user
      authenticate_or_request_with_http_basic("#{I18n.t'authentication_required'}") do |username, password|
        @current_user = User.authenticate(username, password)
      end
    end
  end

  def marek_crypt(mastr)
    tostr = ''
    mastr.tr!("A-Za-z", "N-ZA-Mn-za-m")
    mastr.split('').each do |c|
      randnum = rand(2)+1
      tostr += randnum.to_s
      randnum.times do
        dol = rand(54); nextdummy = (dol>26) ? rand(9).to_s : (rand(26)+64).chr
        tostr += nextdummy
      end
      if c == '/'
        tostr += '0'+rand(4).to_s
      elsif c == '@'
        tostr += '0'+(rand(4)+5).to_s
      elsif c == ' '
        tostr += '1'+rand(4).to_s
      elsif c == '.'
        tostr += '1'+(rand(4)+5).to_s
      else
        tostr += (rand(8)+2).to_s+c
      end
    end
    tostr
  end


end
