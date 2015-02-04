require 'pixways'
class Vingtmins::Photo20minsController < ApplicationController

  layout "simple_provider"

  before_filter :login_required
  before_filter :load_cached_search_params, :only => [:index, :uploads_to_csv]

  def index
    if params[:per_page]
      per_page = params[:per_page]
    elsif @current_params[:per_page]
      per_page = @current_params[:per_page]
    else
      per_page = 60
    end

    page = 1
    page = params["page"].to_i if params["page"] && params["page"].to_i > 0

    unless @current_params[:search_since]
      if cookies[:stats_since].present?
        @current_params[:search_since] = cookies[:stats_since]
      else
        @current_params[:search_since] = "1_month"
      end
    end
    cookies[:stats_since] = @current_params[:search_since]

    l_prov = []
    @providers = Provider.where('input_dir = "/home/photolocal/" and string_key != "LocalAfp"').order(:name)
    @providers.each{|p| l_prov << p.id}

    cearch = {}
    sort = 'reception_date desc'
    sort = @current_params["sort"] if @current_params["sort"]

    cearch[:per_page] = per_page
    cearch[:page] = params["page"].to_i if params["page"] && params["page"].to_i > 0

    with = {}
    with[:content_error]  = 0
    providers_list = @current_params[:providers].nil? || @current_params[:providers].count == 0 ? l_prov : @current_params[:providers].keys.collect!{|e| e.to_i}
    with[:provider_id] = providers_list
    with[:updated_at] = Pixways::SearchesHelper.dates_to_range('',params[:search_time]) if params[:search_time]
    if params[:search_since] && params[:search_since] != 'all'
        with[:reception_date] = Image.since_conditions(@current_params[:search_since])
    end
    with[:reception_date] = Pixways::SearchesHelper.dates_to_range(params[:reception_date_begin], params[:reception_date_end]) unless (params[:reception_date_begin].blank? && params[:reception_date_end].blank?)
    cearch[:with] = with

    cearch[:retry_stale] = true

    @uploads = Image.search with: with, order: sort, per_page: per_page, page: page
    @nb_up = {}
    facets = Image.facets("", cearch.except(:page, :per_page))
    @nb_up = facets[:provider_id]

    respond_to do|format|
      format.html { render stream: true, layout: "statistics" }
      format.js { render stream: true }
      format.csv {send_data Image.uploads_to_csv(@uploads), filename: "envois_" + Time.now.strftime("%Y-%m-%d_%H-%M") + ".csv", type: 'text/csv; charset=utf-8; header=present'}
    end

  end

  def create
    @photo = Photo20min.new(permitted_params)

    if @photo.save
      redirect_to :action => 'edit', :id => @photo.id
    else
      redirect_to action: :new
    end
  end

  def update
    @photo = Photo20min.find(params[:id])
    @w = EXIFR::JPEG.new("public#{@photo.photo.url}").width
    @h = EXIFR::JPEG.new("public#{@photo.photo.url}").height
    @m = EXIFR::JPEG.new("public#{@photo.photo.url}").model
    if @photo.update_attributes(permitted_params)

      photo = Photo20min.find(@photo.id)
      photo_name = photo.photo_identifier
      name_txt = photo_name.gsub(".jpg", "")
      name_txt.gsub!(".JPG", "")
      name_txt = "#{name_txt}.csv"
      import_dir = "1"
      target  = "public/#{name_txt}"
      content = "2:55,2:105,2:120,2:121,2:101,2:90,2:80,2:110,2:115,2:116,2:25,2:40,3:213,3:220,3:230,3:255\n"
      content += "\"" + photo.date_photo.to_s + "\","
      content += "\"" + photo.reportage.to_s + "\","
      content += "\"" + photo.description + "\","
      content += "\"" + photo.reportage.to_s + "\","
      content += "\"\","
      content += "\"\","
      content += "\"\","
      content += "\"\","
      content += "\"\","
      content += "\"" + photo.credit + "\","
      content += "\"" + photo.keywords.to_s + "\","
      content += "\"\","
      content += "\"\","
      content += "\"\","
      content += "\"\","
      content += "\"" + import_dir + "\"\n"

      File.open(target, "w+:UTF-8") do |f|
        f.write(content)
      end

      flash[:alert] = "Photo envoyée pour traitement"
      if current_user.city.blank?
         vers = "/mnt/pixpush/Paris/JPEG_CSV/"
      else
         vers = "/mnt/pixpush/#{current_user.city.capitalize}/JPEG_CSV/"
      end
      begin
        FileUtils::cp target, "#{vers}#{name_txt}"
        FileUtils::cp "public/#{@photo.photo_url}", "#{vers}#{photo_name}"
      rescue => e
        logger.info "e = #{e.inspect}"
        flash[:alert] = "Erreur envoi dossier #{e}"
     end
     redirect_to(:action => :new)
    else
      render :action => :edit
    end
  end

  def destroy
  end

  def edit
    @photo = Photo20min.find(params[:id])
    @w = EXIFR::JPEG.new("public#{@photo.photo.url}").width
    @h = EXIFR::JPEG.new("public#{@photo.photo.url}").height
    @m = EXIFR::JPEG.new("public#{@photo.photo.url}").model
    @photo.date_photo = EXIFR::JPEG.new("public#{@photo.photo.url}").date_time
    @photo.description = EXIFR::JPEG.new("public#{@photo.photo.url}").image_description
    @photo.reportage = ""
  end

  def new
    @photo = Photo20min.new
    @user = current_user
  end

  def show
  end


  private
  
  def permitted_params
    params.require(:photo20min).permit!
  end

end
