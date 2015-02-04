require 'pixways'

class PicturesControlController < ApplicationController

  layout "adm_agency"

  before_filter :load_cached_search_params

  def index

    l_providers = []
    @providers = @current_params[:group_id] ? SearchProviderGroupName.find(@current_params[:group_id]).providers : current_user.providers

    tpg = Authorization.where(:title_provider_group_id => TitleProviderGroup.where(title_provider_group_name_id: Title.find(current_user.title_id).title_provider_group_name_id ) )
    tpg.each do |tpg_id|
      l_providers << TitleProviderGroup.find(tpg_id.title_provider_group_id).provider_id
    end
    @pw_providers = Provider.where(:id => l_providers.each{|x| x}, :local => false).order(:name)
    @local_providers = Provider.where(:id => l_providers.each{|x| x}, :local => true).order(:name)

    if current_user.is_superadmin?
      @pw_providers = @providers.where(:local => false)
      @local_providers = @providers.where(:local => true)
    end

    @err_id = []
    @err_code = {}
    @err_prov = {}
    @err_date = {}
    @err_file = {}
    @err_vig = {}
    @err_im_id = {}
    @taberr = {"err1"=>0, "err2"=>0, "err3"=>0, "err4"=>0, "err5"=>0, "err6"=>0, "err7"=>0, "err8"=>0, "err9"=>0, "err10"=>0, "err11"=>0, "err12"=>0, "err13"=>0, "err14"=>0}
    client = Mysql2::Client.new(:host => "192.168.203.1", :username => "mspixfr", :password => "isa1956", :secure_auth => false, :database => "main_server")

    liste_prov = "("
    if @current_params[:providers].blank?
      @pw_providers.collect{|p| liste_prov << "'#{p.string_key}',"}
    else
      @current_params[:providers].keys.collect{|p| liste_prov << "'#{Provider.find(p).string_key}',"}
    end
    liste_prov.chop! << ")"
    client.query("SELECT distinct mtpa_id, mtpa_param3, mtpa_param1, mtpa_created_at, mtpa_param2, mtpa_param4 FROM MessageToPA where mtpa_done = 0 and mtpa_param1 in #{liste_prov} and mtpa_param5 in ('0', '1') and mtpa_message='1' order by mtpa_created_at DESC").each do |row|
      id = row["mtpa_id"]
      error_code = row["mtpa_param3"].to_i
      if error_code < 6 || error_code == 14
        @err_id << id
        @err_code[id] = error_code
        @err_prov[id] = row["mtpa_param1"]
        @err_date[id] = row["mtpa_created_at"]
        @err_file[id] = row["mtpa_param4"]
        @err_im_id[id] = 0
      else
        ms_id = row["mtpa_param2"].to_i
        #logger.info(" erreur code = #{error_code} ms_id = #{ms_id}")
        unless Image.find_by_ms_image_id(ms_id).nil?
          @err_id << id
          @err_code[id] = error_code
          @err_prov[id] = row["mtpa_param1"]
          @err_date[id] = row["mtpa_created_at"]
          @err_file[id] = row["mtpa_param4"]
          @err_im_id[id] = 0
          @err_vig[id] = Image.find_by_ms_image_id(ms_id).thumb_location
          @err_im_id[id] = Image.find_by_ms_image_id(ms_id).id
        end
      end

      @taberr["err#{@err_code[id]}"] += 1 unless @err_code[id].nil?
    end

    client.close

    render 'adm_agency/pictures_control', :stream => true

  end

def edit
  record_id = params[:record_id]
  client = Mysql2::Client.new(:host => "192.168.203.1", :username => "mspixfr", :password => "isa1956", :secure_auth => false, :database => "main_server")
  client.query("use main_server")
  client.query("update MessageToPA set mtpa_done=1 where mtpa_id = #{record_id}")
  client.close
  redirect_to :pictures_control
end


  private

end
