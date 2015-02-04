class Admin::ProvidersController < ApplicationController
  layout nil
  skip_before_filter :login_required


  def index
    @providers = Provider.where({:local => false}).order(:name).all
    @local_providers = Provider.where({:local => true}).order(:name).all
    render :layout => nil
  end

  def new
    @provider = Provider.new
    @provider.provider_contacts.build
    render :layout => nil
  end

  def create
    @provider = Provider.new(permitted_params)
    if @provider.save
      redirect_to(:action => :edit, :notice => I18n.t('successfully_created'), :id => @provider.id)
    else
      render :action => :new, :layout => nil
    end
  end

  def edit
    @provider = Provider.find(params[:id])
    @provider.provider_contacts.build
    render :layout => 'simple_provider'
  end

  def update
    @provider = Provider.find(params[:id])
    if @provider.update_attributes(permitted_params)
      redirect_to(:action => :edit, :notice => I18n.t('successfully_created'))
    else
      render :action => :edit, :layout => 'simple_provider'
    end
  end

  def destroy
    @provider = Provider.find(params[:id])
    flash[:notice] = I18n.t('deleted') if @provider.destroy
  end

  def show
    @provider = Provider.find(params[:id])
  end

  private
  
  def permitted_params
    params.require(:provider).permit!
  end

end
