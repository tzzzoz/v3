class ServersController < ApplicationController

  layout "window"
#
#  def create
#    @server = Server.new(params[:server])
#
#    if @server.save
#        redirect_to(@server, :notice => I18n.t('successfully_created'))
#    else
#        render :action => :new
#    end
#  end
#
#  def update
#    @server = Server.find(params[:id])
#    if @server.update_attributes(params[:server])
#      redirect_to(@server, :notice => I18n.t('successfully_updated'))
#    else
#      render :action => :edit
#    end
#  end
#
#  def destroy
#    @server = Server.find(params[:id])
#    @server.destroy
#    redirect_to(servers_url)
#  end
#
#  def index
#    @servers = Server.all
#  end
#
#  def edit
#    @server = Server.find(params[:id])
#  end
#
#  def new
#    @server = Server.new
#  end
#
#  def show
#    @server = Server.find(params[:id])
#  end
# private
# def permitted_params
#	# if there are some sensitive fileds, it should be filtered out here.
# 	params.require(:server).permit!
# end

end
