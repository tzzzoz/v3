require 'csv'

class MediasController < ApplicationController
layout "medias"

  def index
    current_params = {}
    @pagin = false
    @no_search = false
    @feature_value = nil
    @notitle = 0
    @notitle = 1 if current_user.title_id == 23 || current_user.title_id == 24 || current_user.title_id == 26
    #    u_id = current_user.id
    if params[:ids]
#      clic_save(4,u_id,3)
      @medias =  Image.where(:id => params[:ids]).sort_by{ |media| params[:ids].index(media.id.to_s) }
    elsif params[:saved_search_id]
#      clic_save(4,u_id,0)
      @pagin = true
      @no_search = true
      current_params = SavedSearch.find(params[:saved_search_id]).criteria
      cearch = {}
      sort = "by_#{params[:sort]}"
      cearch[:per_page] = params[:per_page].to_i
      cearch[:page] = params[:page].to_i if params[:page] && params[:page].to_i > 0
      cearch[:conditions] = Image.params_to_conditions(current_params)
      with = {}
      with[:provider_id] = current_params[:providers].nil? || current_params[:providers].count == 0 ? session[:provs] : current_params[:providers].keys.collect!{|e| e.to_i}
      if current_params[:ratio] == 'square'
        with[:ratio] = 0.98..1.02
      elsif current_params[:ratio] == 'horizontal'
        with[:ratio] = 1.02..9999.0
      elsif current_params[:ratio] == 'vertical'
        with[:ratio] = 0.01..0.98
      elsif current_params[:ratio] == 'panoramic'
        with[:ratio] = 1.7..9999.0
      end

      with[:fonds] = 0 if params[:media_typ] == 'photos'
      with[:fonds] = 1 if params[:media_typ] == 'videos'
      with[:content_error]  = 0
      with[:updated_at] = Pixways::SearchesHelper.dates_to_range('',current_params[:search_time]) if current_params[:search_time]
      if current_params[:search_since] && current_params[:search_since] != 'all'
        current_time = Time.now
        current_time -= current_time.utc_offset
        upper_bound = 2145913199
        with[:reception_date] = (current_time - 1.day).to_i..upper_bound
      end
      with[:reception_date] = Pixways::SearchesHelper.dates_to_range(current_params[:reception_date_begin], current_params[:reception_date_end]) unless (current_params[:reception_date_begin].blank? && current_params[:reception_date_end].blank?)
      with[:date_created] = Pixways::SearchesHelper.dates_to_range(current_params[:date_created_begin], current_params[:date_created_end])     unless (current_params[:date_created_begin].blank? && current_params[:date_created_end].blank?)
      cearch[:with] = with
      cearch[:excerpts] = {:limit => 1024}
      keywords = current_params[:key_words] ? Pixways::SearchesHelper.filter_keywords(current_params[:key_words]) : ''
      @medias = Image.instance_eval(sort).search(keywords, cearch)
      @medias.context[:panes] << ThinkingSphinx::Panes::ExcerptsPane
    elsif params[:search]
#      clic_save(4,u_id,0)
      @pagin = true
      @no_search = true
      current_params = Rails.cache.read(params[:search])
      cearch = {}
      sort = "by_#{params[:sort]}"
      cearch[:per_page] = params[:per_page].to_i
      cearch[:page] = params[:page].to_i if params[:page] && params[:page].to_i > 0
      cearch[:conditions] = Image.params_to_conditions(current_params)
      with = {}
      with[:provider_id] = current_params[:providers].nil? || current_params[:providers].count == 0 ? session[:provs] : current_params[:providers].keys.collect!{|e| e.to_i}
      if current_params[:ratio] == 'square'
        with[:ratio] = 0.98..1.02
      elsif current_params[:ratio] == 'horizontal'
        with[:ratio] = 1.02..9999.0
      elsif current_params[:ratio] == 'vertical'
        with[:ratio] = 0.01..0.98
      elsif current_params[:ratio] == 'panoramic'
        with[:ratio] = 1.7..9999.0
      end

      with[:fonds] = 0 if params[:media_typ] == 'photos'
      with[:fonds] = 1 if params[:media_typ] == 'videos'
      with[:content_error]  = 0
      with[:updated_at] = Pixways::SearchesHelper.dates_to_range('',current_params[:search_time]) if current_params[:search_time]
      if current_params[:search_since] && current_params[:search_since] != 'all'
        current_time = Time.now
        current_time -= current_time.utc_offset
        upper_bound = 2145913199
        with[:reception_date] = (current_time - 1.day).to_i..upper_bound
      end
      with[:reception_date] = Pixways::SearchesHelper.dates_to_range(current_params[:reception_date_begin], current_params[:reception_date_end]) unless (current_params[:reception_date_begin].blank? && current_params[:reception_date_end].blank?)
      with[:date_created] = Pixways::SearchesHelper.dates_to_range(current_params[:date_created_begin], current_params[:date_created_end])     unless (current_params[:date_created_begin].blank? && current_params[:date_created_end].blank?)
      cearch[:with] = with
      cearch[:excerpts] = {:limit => 1024}
      keywords = current_params[:key_words] ? Pixways::SearchesHelper.filter_keywords(current_params[:key_words]) : ''
      @medias = Image.instance_eval(sort).search(keywords, cearch)
      @medias.context[:panes] << ThinkingSphinx::Panes::ExcerptsPane
    elsif params[:reportage]
#      clic_save(4,u_id,1)
      @feature_value = params[:reportage]
      @medias = Image.where(:reportage => params[:reportage], :content_error => false, :provider_id => params[:provider_id])
      @feature_number = @medias.count
    elsif params[:offre]
#      clic_save(4,u_id,2)
      @offre = params[:offre].to_i
      rep = Reportage.find(@offre)
      @feature_value = rep.rep_titre
      @feature_number = rep.nb_photos
      @feature_text = rep.rep_texte
      @medias = ReportagePhoto.where(:reportage_id => rep.id).order(:rang).collect{|p| Image.find_by_ms_image_id(p.photo_ms_id)}
    elsif params[:light_box]
#      clic_save(4,u_id,3)
      @feature_value = "1"
      @medias =  current_user.light_boxes.find(params[:light_box]).images.order_by_light_box_position_desc
    else
#      clic_save(4,u_id,4)
      @pagin = true
      current_time = Time.now
      current_time -= current_time.utc_offset
      upper_bound = 2145913199

      cearch = {}
      with = {}
      with[:provider_id] = session[:provs]
      with[:content_error] = 0
      with[:reception_date] = (current_time - 1.day).to_i..upper_bound
      with[:fonds] = 0 if params[:media_typ] == 'photos'
      with[:fonds] = 1 if params[:media_typ] == 'videos'
      sort = "by_#{params[:sort]}"
      cearch[:per_page] = params[:per_page].to_i
      cearch[:page] = params[:page].to_i if params[:page] && params[:page].to_i > 0
      cearch[:conditions] = {}
      cearch[:with] = with
      @medias = Image.instance_eval(sort).search('', cearch)
    end
    render :stream => true
  end
end
