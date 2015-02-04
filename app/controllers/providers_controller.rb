class ProvidersController < ApplicationController
  layout 'simple'

  def index
    @providers = session[:provs].collect{|p| Provider.find(p)}
#    clic_save(6,current_user.id,0)
    respond_to do |format|
      format.html
      format.csv { send_data Provider.export_to_csv(@providers), :filename => "contacts.csv", :type => 'text/csv; charset=utf-8; header=present'}
    end
  end

  def provkey
    @prov = Provider.where(:string_key => params[:string_key])

    respond_to do |format|
      format.xml { render :xml => @prov }
      format.json { render json: @prov }
    end
  end

end
