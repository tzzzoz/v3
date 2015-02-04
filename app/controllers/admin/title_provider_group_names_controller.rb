class Admin::TitleProviderGroupNamesController < ApplicationController

  before_filter :login_required

  def index
    params.reject!{|k,v| v.blank?}
    if params[:country_id]
      @country_id = params[:country_id]
      @title_provider_group_names = TitleProviderGroupName.order("name ASC").where(:country_id => params[:country_id] )
    else
      @title_provider_group_names = TitleProviderGroupName.order("name ASC").all
    end
    @title_provider_group_name_id = params[:id]
    @titles = Title.where(title_provider_group_name_id: @title_provider_group_name_id)
    render :layout => nil
  end

  def show
    @title_provider_group_name = TitleProviderGroupName.find(params[:id])
    @country_name = Country.find(@title_provider_group_name.country_id).name
    @all_permission_labels = PermissionLabel.where(:id => 3)
    @all_permission_labels += PermissionLabel.where(:id => 1)
    @all_permission_labels += PermissionLabel.where(:id => 2)
    render :layout => nil

  end

  def new
    @all_permission_labels = PermissionLabel.where(:id => 3)
    @all_permission_labels += PermissionLabel.where(:id => 1)
    @all_permission_labels += PermissionLabel.where(:id => 2)
    @title_provider_group_name = TitleProviderGroupName.new(:country_id => params[:country_id])
    Provider.order('name').each do |p|
      @title_provider_group_name.title_provider_groups.build(:provider_id => p.id)
    end
    render :action => :edit
  end

  def create
    @all_permission_labels = PermissionLabel.where(:id => 3)
    @all_permission_labels += PermissionLabel.where(:id => 1)
    @all_permission_labels += PermissionLabel.where(:id => 2)
    @title_provider_group_name = TitleProviderGroupName.new({:name => params[:title_provider_group_name][:name], :country_id =>  params[:title_provider_group_name][:country_id]})
    flash[:notice] = I18n.t('successfully_created') if @title_provider_group_name.save
    flash[:notice] = I18n.t('successfully_created') if @title_provider_group_name.update_attributes(permitted_params)
    render :layout => nil
    #redirect_to admin_title_provider_group_name_path(@title_provider_group_name, :format => :js) unless @title_provider_group_name.nil?

  end

  def edit
    @all_permission_labels = PermissionLabel.where(:id => 3)
    @all_permission_labels += PermissionLabel.where(:id => 1)
    @all_permission_labels += PermissionLabel.where(:id => 2)
    @title_provider_group_name = TitleProviderGroupName.find(params[:id])

    new_provs_id = Provider.order('name').collect{|p| p.id} - @title_provider_group_name.providers.collect{|p| p.id}
    new_provs_id.each do |p_id|
      @title_provider_group_name.title_provider_groups.build(:provider_id => p_id)
    end

  end

  def update
    @title_provider_group_name = TitleProviderGroupName.find(params[:id])
    flash[:notice] = I18n.t('successfully_updated') if @title_provider_group_name.update_attributes(permitted_params)
    #redirect_to :action => :edit, :format => :js
  end

  def destroy
    @title_provider_group_name = TitleProviderGroupName.find(params[:id])
    @titles = Title.where(title_provider_group_name_id: @title_provider_group_name)
    if @titles.empty?
      @title_provider_group_name.destroy
    end
    render :layout => nil
  end

  private
  
  def permitted_params
    params.require(:title_provider_group_name).permit!
  end

end
