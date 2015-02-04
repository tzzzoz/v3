class ReportagesController < ApplicationController

  #require "capistrano"

  layout "adm_agency"

  #before_filter :adm_login_required, :except => ["liste"]
  before_filter :load_cached_search_params, :only => ["index", "liste"]

  helper_method :sort_column, :sort_direction

  def create
    @reportage = Reportage.new(permitted_params)
    if @reportage.save
        ids = []
        ids = params[:reportage][:prem_photo].split("&")
        ids.map!{|s| s.to_i}
        im = Image.find(ids[0])
        Reportage.update(@reportage.id, :no_reportage => "#{@reportage.no_reportage}_#{@reportage.id}", :prem_photo => im.ms_image_id, :nb_photos => ids.count, :signatur => im.normalized_credit, :offre => 1)
        rang = 0
        ids.each do |i|
          img = Image.find(i).ms_image_id
          ReportagePhoto.create(:reportage_id => @reportage.id, :photo_ms_id => img, :rang => rang)
          rang += 1
        end
        redirect_to(:action => :index, :notice => I18n.t('successfully_created'))
    else
        redirect_to(:action => :new, :id => params[:lbid], :notice => "Erreur lors de création du reportage")
    end
  end

  def update
    @reportage = Reportage.find(params[:id])
    if @reportage.update_attributes(permitted_params)
      ids = []
      ids = params[:reportage][:prem_photo].split("&")
      ids.map!{|s| s.to_i}
      im = Image.find(ids[0])
      Reportage.update(@reportage.id, :prem_photo => im.ms_image_id, :nb_photos => ids.count, :signatur => im.normalized_credit)
      ReportagePhoto.where(:reportage_id => @reportage.id).collect{|p| p.destroy}
      rang = 0
      ids.each do |i|
        img = Image.find(i).ms_image_id
        ReportagePhoto.create(:reportage_id => @reportage.id, :photo_ms_id => img, :rang => rang)
        rang += 1
      end
      redirect_to(:action => :index,:keyword => params[:keyword],:liste_providers => params[:liste_providers],:offres_reportages => params[:offres_reportages],:sort=>params[:sort],:direction=>params[:direction], :notice => I18n.t('successfully_updated'))
    else
      render :edit
    end
  end

  def destroy
    rep = Reportage.find(params[:id])
    rep.destroy
  end

  def index
    @providers = Provider.find_my_provs(session[:provhd])
    @pw_providers = @providers.where(:local => false)
    @local_providers = @providers.where(:local => true)

    if params[:liste_providers].blank?
      liste_prov = "("
      params[:liste_providers]=""
      if params[:providers].blank?
        @pw_providers.collect{|p| liste_prov << "'#{p.string_key}',"}
      else
        params[:providers].keys.collect do |p|
          liste_prov << "'#{Provider.find(p).string_key}',"
          params[:liste_providers] << "#{p},"
        end
      end
      liste_prov.chop! << ")"
      params[:liste_providers].chop!
    else
      liste_providers_array = params[:liste_providers].split(',')
      liste_prov = "("
      liste_providers_array.each do |p|
        liste_prov << "'#{Provider.find(p).string_key}',"
        params[:providers]["#{p}"] = '1'
        end
      liste_prov.chop! << ")"
    end

    params[:offres_reportages]||=1

    params[:keyword].strip! if params[:keyword]
    if params[:keyword].blank?
      @nb_rep = Reportage.where("string_key in #{liste_prov} and offre = 0").count
      @nb_off = Reportage.where("string_key in #{liste_prov} and offre = 1").count
      @reportages = Reportage.where("string_key in #{liste_prov} and offre = #{params[:offres_reportages]}").order(sort_column + " " + sort_direction).page params[:page]
    else
      keyw = params[:keyword].gsub(/['"\\\x0]/,'\\\\\0')
      @nb_rep = Reportage.where("rep_titre like '%#{keyw}%' and string_key in #{liste_prov} and offre = 0").count
      @nb_off = Reportage.where("rep_titre like '%#{keyw}%' and string_key in #{liste_prov} and offre = 1").count
      @reportages = Reportage.where("rep_titre like '%#{keyw}%' and string_key in #{liste_prov} and offre = #{params[:offres_reportages]}").order(sort_column + " " + sort_direction).page params[:page]
    end
  end

  def edit
    @reportage = Reportage.find(params[:id])
    @images = ReportagePhoto.where(:reportage_id => params[:id]).order(:rang).collect{|p| Image.find_by_ms_image_id(p.photo_ms_id)}
  end

  def new
    @light_box = LightBox.find(params[:id])
    name_tst = @light_box.name.split("_")
    rep = Reportage.where(:string_key => name_tst.first, :id => name_tst.second.to_i).first
    images = []
    @light_box.images.where(:content_error => 0).collect{|i| images << i if session[:provhd][Image.find(i).provider_id] == 1}
    @images = images.collect{|i| Image.find(i)}
    if rep.nil?
      @reportage = Reportage.new(:no_reportage => @light_box.name, :string_key => Provider.find(@images.first.provider_id).string_key, :nb_photos => @images.count, :signatur => @images.first.normalized_credit, :rep_date => Date.today)
    else
      @reportage = Reportage.new(:no_reportage => rep.no_reportage, :string_key => rep.string_key, :nb_photos => @images.count, :signatur => @images.first.normalized_credit, :rep_date => rep.rep_date, :rep_titre => rep.rep_titre, :rep_texte => rep.rep_texte)
      rep.destroy
    end
  end

  def show
    rep_id = params[:id]
    lb_name = "#{Reportage.find(rep_id).string_key}_#{rep_id}"
    LightBox.where(:name => lb_name).collect{|v| v.destroy}
    lb = LightBox.create(:name => lb_name, :user_id => current_user.id, :title_id => current_user.title_id)
    lb.save!
    ReportagePhoto.where(:reportage_id => rep_id).order(:rang).collect{|p| lb.light_box_images.create(:image_id => Image.find_by_ms_image_id(p.photo_ms_id).id, :position => p.rang)}
    session[:active_light_box] = lb.id
    redirect_to(home_path)
  end

  def liste
    @list_rep = []
    Panier.where(:user_id => current_user.id).collect{|r| @list_rep << r.reportage_id}

    @providers = Provider.where(:id => session[:provs]).order(:name)
    @pw_providers = @providers.where(:local => false)
    @local_providers = @providers.where(:local => true)

    if params[:liste_providers].blank?
      liste_prov = "("
      params[:liste_providers]=""
      if params[:providers].blank?
        @pw_providers.collect{|p| liste_prov << "'#{p.string_key}',"}
      else
        params[:providers].keys.collect do |p|
          liste_prov << "'#{Provider.find(p).string_key}',"
          params[:liste_providers] << "#{p},"
        end
      end
      liste_prov.chop! << ")"
      params[:liste_providers].chop!
    else
      liste_providers_array = params[:liste_providers].split(',')
      liste_prov = "("
      liste_providers_array.each do |p|
        liste_prov << "'#{Provider.find(p).string_key}',"
        params[:providers]["#{p}"] = '1'
      end
      liste_prov.chop! << ")"
    end


    params[:offres_reportages]||=1

    if params[:panier]
      #clic_save(7,current_user.id,2)
      @nb_rep = Reportage.where("string_key in #{liste_prov} and updated_at > '#{Date.today - 4.days}' and nb_photos > 1 and rep_titre != '' and offre = 0").count
      @nb_off = Reportage.where("string_key in #{liste_prov} and nb_photos > 1 and rep_titre != '' and offre = 1").count
      @reportages = Reportage.where(:id => @list_rep).order(sort_column + " " + sort_direction).page params[:page]
    else
      params[:keyword].strip! if params[:keyword]
      if params[:keyword].blank?
        #clic_save(7,current_user.id,0)
        @nb_rep = Reportage.where("string_key in #{liste_prov} and updated_at > '#{Date.today - 4.days}' and nb_photos > 1 and rep_titre != '' and offre = 0").count
        @nb_off = Reportage.where("string_key in #{liste_prov} and nb_photos > 1 and rep_titre != '' and offre = 1").count
        if params[:offres_reportages].to_i==0
          updated_criteria = "and updated_at > '#{Date.today - 4.days}'"
        else
          updated_criteria =""
        end
        @reportages = Reportage.where("string_key in #{liste_prov} #{updated_criteria} and nb_photos > 1 and rep_titre != '' and offre = #{params[:offres_reportages]}").order(sort_column + " " + sort_direction).page params[:page]
      else
        #clic_save(7,current_user.id,1)
        keyw = params[:keyword].gsub(/['"\\\x0]/,'\\\\\0')
        @nb_rep = Reportage.where("rep_titre like '%#{keyw}%' and string_key in #{liste_prov} and offre = 0").count
        @nb_off = Reportage.where("rep_titre like '%#{keyw}%' and string_key in #{liste_prov} and offre = 1").count
        @reportages = Reportage.where("rep_titre like '%#{keyw}%' and string_key in #{liste_prov} and offre = #{params[:offres_reportages]}").order(sort_column + " " + sort_direction).page params[:page]
      end
    end
    @nb_panier = @list_rep.count
  end

  private

  def sort_column
    Reportage.column_names.include?(params[:sort]) ? params[:sort] : "updated_at"
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
  end

  def permitted_params
    params.require(:reportage).permit(:rep_titre, :rep_texte, :rep_date)
  end
  
end