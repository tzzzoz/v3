require "mysql2"
require 'net/ftp'

class RequestToProvidersController < ApplicationController

  def index
    u = current_user
    @request_to_providers = u.request_to_providers
#    clic_save(8, u.id, 0)
    render :layout => nil
   end

  def show
    request = current_user.request_to_providers.find(params[:id].to_i)
    if request
      @provider_response_to_request = request.provider_responses_to_request.paginate(:page      => (params[:page] || 1).to_i, 
                                                                                     :per_page  => params[:per_page])
    end
    render :layout => nil
  end

  def new
    @request_to_providers = RequestToProvider.new
    render :layout => nil
  end

  def edit
     @request_to_provider = RequestToProvider.find(params[:id])
     @img_nb = Reqphoto.where(:request_to_provider_id => params[:id]).count
     prov_id = SelectedProvidersForRequest.find_by_request_to_provider_id(@request_to_provider.id).provider_id
     imgs = []
     Reqphoto.where(:request_to_provider_id => params[:id]).collect{|rtp| imgs << rtp.reqphoto_file_name} unless @img_nb == 0
     @img = Image.where(:original_filename => imgs, :provider_id => prov_id)
     render :layout => "adm_agency"
  end

  def create
    u = current_user
#    clic_save(8, u.id, 1)
     provs = []
      if params[:providers].nil?
        prov = u.providers
      else
        provs = params[:providers].keys
      end
      serial = gen_serial(u)
      serial = gen_serial(u) while !RequestToProvider.find_by_serial(serial).nil?

      request = RequestToProvider.new(
        :text    => params[:text],
        :user_id => u.id,
        :serial  => serial
      )
      if request.save!
        provs.each do |provider_id|
          SelectedProvidersForRequest.create!(:provider_id => provider_id, :request_to_provider_id => request.id)
          Delayed::Job.enqueue ForwardRequestJob.new(params[:text], u.login, serial, Provider.find(provider_id).string_key)
        end
      end
      @request_to_providers = u.request_to_providers
      redirect_to :action => :index
  end

  def update
    @request_to_provider = RequestToProvider.find(params[:id])
    folder = @request_to_provider.serial
    prov = Provider.find(SelectedProvidersForRequest.find_by_request_to_provider_id(@request_to_provider.id).provider_id).name
    client = Mysql2::Client.new(:host => "192.168.203.1", :username => "mspixfr", :password => "isa1956")
    client.query("use main_server")
    row =  client.query("SELECT inDir_path FROM InputDirectories LEFT JOIN Agences on Agences.id=InputDirectories.inDir_agencyId where Agences.agencyName='#{prov}' and inDir_type = 1 limit 1")
    inDir = row.first["inDir_path"]
    client.close

    inDir.gsub!("/usr/PPserver/in/","")
    ftp = Net::FTP.new("192.168.200.3")
    ftp.passive = true
    ftp.login("pixadmin", "meepao9a")
    ftp.chdir(inDir)
    ftp.mkdir(folder)
    ftp.chdir(folder)

    unless params[:rphoto].blank?
      params[:rphoto].each do |photo|
        File.open("/tmp/#{photo.original_filename}", "wb") do |file|
          file.write(photo.read)
          ftp.putbinaryfile(file)
        end
        reqphoto = Reqphoto.new(:reqphoto_file_name => photo.original_filename, :request_to_provider_id => @request_to_provider.id)
        reqphoto.save
      end
    end
    ftp.close
    redirect_to adm_agency_path
  end

  def destroy
    RequestToProvider.find(params[:id]).destroy
#    clic_save(8, current_user.id, 2)
    render :layout => nil
  end

  def cs_request
    r_text = params[:text]
    login = params[:login]
    user = User.find_by_login(login)
    serial = params[:serial]
    prov = Provider.find_by_string_key(params[:stringkey])
    email_list = []

    request = RequestToProvider.new(
      :text    => r_text,
      :user_id => user.id,
      :serial  => serial
    )
    subject = "Requete depuis PixPalace de : #{login} #{user.title.name}"

    if request.save!
        SelectedProvidersForRequest.create!(:provider_id => prov.id, :request_to_provider_id => request.id)
        prov.provider_contacts.where(:receive_requests => true).collect{|pc| email_list << pc.email}
    end

    mail = UserMailer.send_request_to_provider((email_list rescue nil), r_text, "FTP dir : #{serial}", subject, user.email).deliver

    respond_to do |f|
      f.xml  { render :xml => request, :status => :created }
    end

  end

   private

   def gen_serial(user)
     title = user.title.name
     server = user.title.server.name
     serial = "#{title}_#{server}_"
     5.times do
       rnd = rand(52)
       serial += (rnd > 25) ? rand(10).to_s : (65+rnd).chr
     end
     serial
   end

end
