require 'pixways'

class RtpController < ApplicationController

  layout "adm_agency"

  before_filter :load_cached_search_params

  def index

    l_providers = []
    @providers = @current_params[:group_id] ? SearchProviderGroupName.find(@current_params[:group_id]).providers : current_user.providers

    tpg = Authorization.where(:title_provider_group_id => TitleProviderGroup.where(title_provider_group_name_id: Title.find(current_user.title_id).title_provider_group_name_id) )
    tpg.each do |tpg_id|
      l_providers << TitleProviderGroup.find(tpg_id.title_provider_group_id).provider_id
    end
    @pw_providers = Provider.where(:id => l_providers.each{|x| x}, :local => false).order(:name)
    @local_providers = Provider.where(:id => l_providers.each{|x| x}, :local => true).order(:name)

    if current_user.is_superadmin?
      @pw_providers = @providers.where(:local => false)
      @local_providers = @providers.where(:local => true)
    end

    prov=[]
    if @current_params[:providers].blank?
      @pw_providers.collect{|p| prov << p.id}
    else
      @current_params[:providers].keys.collect{|p| prov << p.to_i}
    end

    @rtp = RequestToProvider.joins(:selected_providers_for_requests).where(:selected_providers_for_requests => {:provider_id => prov}).order('created_at desc')
    @rtp.uniq!

    render 'adm_agency/rtp', :stream => true

  end

end
