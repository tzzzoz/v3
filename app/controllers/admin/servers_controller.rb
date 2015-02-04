class Admin::ServersController < ApplicationController

  before_filter :login_required

  def create
    @server = Server.new(permitted_params)

    if @server.save
        redirect_to([:admin, @server], :notice => I18n.t('successfully_created'))
    else
        render :action => :new, :layout => nil
    end
  end

  def update
    @server = Server.find(params[:id])
    if @server.update_attributes(permitted_params)
      redirect_to([:admin, @server], :notice => I18n.t('successfully_updated'))
    else
      render :action => :edit, :layout => nil
    end
  end

  def destroy
    @server = Server.find(params[:id])
    @server.destroy
  end

  def index
    @servers = Server.all
    render :layout => nil
  end

  def edit
    @server = Server.find(params[:id])
    render :layout => nil
  end

  def new
    @server = Server.new
    render :layout => nil
  end

  def show
    @server = Server.find(params[:id])
    render :layout => nil
  end

  private
  
  def permitted_params
    params.require(:server).permit(:name, :which_type, :status, :is_self, :host, :api_key, :api_port)
  end

end
