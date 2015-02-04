class TitleProviderGroupsController < ApplicationController

  def index
    @permissions_label = PermissionLabel.all
    respond_to do |format|
      format.xml  { render :xml => @permissions_label.to_xml(:dasherize => false)}
    end
  end

  def show
    @title_provider_group_name = TitleProviderGroupName.find(params[:id])
    respond_to do |format|
      format.xml  { render :xml => @title_provider_group_name.providers_with_authorizations_to_xml}
    end
  end

  def create
    @title_provider_group_name = TitleProviderGroupName.new({ :name => params[:name], :country_id => params[:country]})
    if params[:providers]
      params[:providers].values.each do |provider|
        @title_provider_group_name.add_provider(provider)
      end
    end
    respond_to do |format|
        if @title_provider_group_name.save
          @countries = Country.all
          format.xml  { render :xml => @countries.to_xml(:dasherize => false, :include => {:title_provider_group_names =>{ :include => {:titles =>{:methods => :list_dpi}}}}) }
        else
          format.xml  { render :text => "error" }
        end
    end
  end

  def update
    @title_provider_group_name = TitleProviderGroupName.find(params[:id])
    @title_provider_group_name.update_group({ :name => params[:name], :country_id => params[:country], :providers => params[:providers]}) if @title_provider_group_name
    respond_to do |format|
        if @title_provider_group_name.save
          @countries = Country.all
          format.xml  { render :xml => @countries.to_xml(:dasherize => false, :include => {:title_provider_group_names =>{ :include => {:titles =>{:methods => :list_dpi}}}}) }
        else
          format.xml  { render :text => "error" }
        end
    end
  end

  def destroy
    @title_provider_group_name = TitleProviderGroupName.find(params[:id])
    if @title_provider_group_name.destroy
      @title_provider_group_name = TitleProviderGroupName.all
      respond_to do |format|
        @countries = Country.all
        format.xml  { render :xml => @countries.to_xml(:dasherize => false, :include => {:title_provider_group_names =>{ :include => {:titles =>{:methods => :list_dpi}}}}) }
      end
    end
  end

end
