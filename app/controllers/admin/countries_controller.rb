class Admin::CountriesController < ApplicationController

  before_filter :login_required

  def create
    @country = Country.new(permitted_params)

    if @country.save
        redirect_to({:action => :index}, :notice => I18n.t('successfully_created'))
    else
        render :action => :new, :layout => nil
    end
  end

  def update
    @country = Country.find(params[:id])
    if @country.update_attributes(permitted_params)
      redirect_to([:admin, @country], :notice => I18n.t('successfully_updated'))
    else
      render :action => :edit, :layout => nil
    end
  end

  def destroy
    @country = Country.find(params[:id])
    @country.destroy
  end

  def index
    @countries = Country.all
    render :layout => nil
  end

  def edit
    @country = Country.find(params[:id])
    render :layout => nil
  end

  def new
    @country = Country.new
    render :layout => nil
  end

  def show
    @country = Country.find(params[:id])
    render :layout => nil
  end

  private
  
  def permitted_params
    params.require(:country).permit(:name)
  end

end
