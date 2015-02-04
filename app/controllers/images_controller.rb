require 'RMagick'
require 'image_size'
require 'rest_client'
include ActionView::Helpers::NumberHelper

class ImagesController < ApplicationController

  def show
    @image = Image.find(params[:id])

    respond_to do |format|
     format.xml { render :xml => @image }
    end
  end

  def tst_jcrop
    if params[:id]
      idi = params[:id].to_i
    else
      idi = 36070272
    end
    @image = Image.find(idi)
    render layout: "simple"
  end

  def valid_crop
    im = Image.find(params[:img].to_i)
    if params[:button]
      redirect_to home_path
    else
     @image = im.medium_location
     @image_id = im.id
     if im.provider_id == 1 || im.provider_id == 11 || im.provider_id == 3
      unless params[:x1].blank?
        @x = params[:x1].to_i
        @y = params[:y1].to_i
        @w = params[:w].to_i
        @h = params[:h].to_i
        img_ori = Magick::Image.read("public#{@image}").first
        img_crop = img_ori.crop(@x,@y,@w,@h)
        img_crop.write("#{Rails.root}/public/c_#{im.original_filename}")
        @image = "/c_#{im.original_filename}"
      end
     end
     render layout: "simple"
    end
  end

  def definitive_crop
    im = Image.find(params[:img].to_i)
    if params[:button]
      redirect_to :action => 'tst_jcrop', :id => im
    else
     if im.provider_id == 1 || im.provider_id == 11 || im.provider_id == 3
       hr_location = "public/#{im.original_filename}"
       get_ms_file(hr_location, im.ms_picture_id, MS[im.ms_id])
     else
      hr_location = im.hires_location
     end
     unless params[:x1].blank?
      x = params[:x1].to_i
      y = params[:y1].to_i
      w = params[:w].to_i
      h = params[:h].to_i
      siz = []
      s = ImageSize.path("public#{im.medium_location}").size
      siz = s.to_s.split('x')
      wm = siz[0].to_f
      hm = siz[1].to_f
      xratio = im.max_avail_width/wm
      yratio = im.max_avail_height/hm
      x = x*xratio
      y = y*yratio
      w = w*xratio
      h = h*yratio
      img_ori = Magick::Image.read(hr_location).first
      img_crop = img_ori.crop(x.to_i,y.to_i,w.to_i,h.to_i)
      img_crop.write("#{Rails.root}/public/c_#{im.original_filename}")
      hr_location = im.original_filename
     end
     @id = im.id
     @img = "c_#{im.original_filename}"
     @s = ImageSize.path("public/#{@img}").size
     conv = []
     conv = @s.to_s.split("x")
     w = (conv[0].to_i/300)*2.54
     h = (conv[1].to_i/300)*2.54
     @cm = "#{w.to_i}x#{h.to_i}"
     @p = number_to_human_size(File.size("public/#{@img}"))
    end
  end

  def horby_send
    if params[:button]
      flash[:alert] = "Téléchargement annulé"
    else
      img_id = params[:id].to_i
      if params[:img]
        hr_location = params[:img]
      else
        im = Image.find(img_id)
        if im.provider_id < 180
          hr_location = "public/#{im.original_filename}"
          get_ms_file(hr_location, im.ms_picture_id, MS[im.ms_id])
        else
          hr_location = im.hires_location
        end
      end
      id20m = envoi_horby(hr_location)
      if id20m == "Erreur"
        flash[:alert] = "Envoi vers Etna impossible"
      else
        Statistic.create(image_id: img_id, user_id: current_user.id, operation_label_id: 2, id20min: id20m)
        FileUtils.rm hr_location
        flash[:alert] = "Image envoyée dans Etna"
      end
    end
    redirect_to home_path
  end


  def print_send
    dossier = []
    dossier = params[:dos].split("@")
    img_id = dossier[1].to_i
    dos = dossier[0]
    im = Image.find(img_id)
    if dossier[2]
      hr_location = "public/#{dossier[2]}"
    else
        hr_location = "public/#{im.original_filename}"
        dossier[2] = im.original_filename
        get_ms_file(hr_location, im.ms_picture_id, MS[im.ms_id])
    end
    flash[:alert] = "Image envoyée dans le dossier Print"
    begin
      FileUtils::mv( hr_location, "#{dos}/#{dossier[2]}" )
      Statistic.create(image_id: img_id, user_id: current_user.id, operation_label_id: 2)
    rescue => e
      logger.info "e = #{e.inspect}"
      flash[:alert] = "Erreur envoi dossier Print"
    end
    redirect_to home_path
  end

  def edit
    @image = Image.find(params[:id])
    @record_id = params[:record_id]
    render :layout => "simple"
  end


  def update
    unless params[:button]
    @image = Image.find(params[:id])
    if @image.update_attributes(permitted_params)
      im = Image.find(params[:id])
      name_txt = im.file_name
      name_txt.gsub!(".jpg", "")
      name_txt.gsub!(".JPG", "")
      name_txt = "#{name_txt}.csv"
      import_dir = "1"
      target  = "public/#{name_txt}"
      content = "2:55,2:105,2:120,2:101,2:90,2:80,2:110,2:115,2:116,2:25,2:40,3:213,3:220,3:230,3:255,3:500\n"
      content += "\"" + im.date_created.to_s + "\","
      content += "\"" + im.headline + "\","
      content += "\"" + im.description + "\","
      content += "\"" + im.country + "\","
      content += "\"" + im.city + "\","
      content += "\"" + im.creator + "\","
      if im.credit.nil?
        content += "\" ,"
      else
        content += "\"" + im.credit + "\","
      end
      content += "\"" + im.source + "\","
      content += "\"" + im.rights + "\","
      content += "\"" + im.subject + "\","
      content += "\"" + im.instructions + "\","
      content += "\"" + im.hires_location + "\","
      content += "\"" + im.original_filename + "\","
      content += "\"" + im.ms_picture_id + "\","
      content += "\"" + import_dir + "\","
      content += "\"" + params[:record_id].to_s + "\"\n"

      File.open(target, "w+:UTF-8") do |f|
        f.write(content)
      end

#
# 20'
#      prov = Provider.find(@image.provider_id).name
#      flash[:alert] = "Photo envoyée pour traitement"
#      vers = "/mnt/pixpush/#{prov.capitalize}/"
#      begin
#        FileUtils::cp target, "#{vers}#{name_txt}"
#      rescue => e
#        logger.info "e = #{e.inspect}"
#        flash[:alert] = "Erreur envoi méta-données #{e}"
#      end
#fin 20'
      prov = Provider.find(@image.provider_id).string_key
      client = Mysql2::Client.new(:host => "192.168.203.1", :username => "mspixfr", :password => "isa1956")
      client.query("use main_server")
      row =  client.query("SELECT inDir_path FROM InputDirectories LEFT JOIN Agences on Agences.id=InputDirectories.inDir_agencyId where Agences.filePrefix='#{prov}' and inDir_type = 1 limit 1")
      inDir = row.first["inDir_path"]
      client.close

      inDir.gsub!("/usr/PPserver/in/","")
      ftp = Net::FTP.new("192.168.200.3")
      ftp.passive = true
      ftp.login("pixadmin", "meepao9a")
      ftp.chdir(inDir)

      ftp.putbinaryfile(target, name_txt)
      ftp.close

      if params[:record_id].empty?
        redirect_to home_path
      else
        client = Mysql2::Client.new(:host => "192.168.203.1", :username => "mspixfr", :password => "isa1956")
        client.query("use main_server")
        client.query("update MessageToPA set mtpa_done=1 where mtpa_id = #{params[:record_id]}")
        client.close

        redirect_to :pictures_control
        #render :action => :edit, :notice => I18n.t('successfully_updated'), :layout => nil
      end

    else
      render :action => :edit
    end
  else
      if params[:record_id].empty?
        redirect_to home_path
      else
        #render :action => :edit, :notice => I18n.t('successfully_updated'), :layout => nil
        redirect_to :pictures_control
      end
  end

  end

  private

  def get_ms_file(orig_file, ms_img_id, url)
    requ = marek_request_build(ms_img_id)
    uri = URI("http://#{url}/cgi-bin/download_pixpalace.zip")
    res = Net::HTTP.post_form(uri, 'from' => requ)
    tempfile = Tempfile.new("wb")
    tempfile.binmode
    tempfile.write(res.body)
    tempfile.rewind
    File.open(orig_file, "wb"){ |f| f.write(tempfile.read) }
    tempfile.close
    tempfile.unlink
  end

  def envoi_horby(img)
    url_key = 'media?upload_to_krakatoa=true&crop_white_borders=true'
    #secret_key = 'secret'
    endpoint_url = "http://dam.20minutes.fr/"

    begin
      res = RestClient.post( "#{endpoint_url}/#{url_key}",
      {
        :file => File.new(img, 'rb')
      }, "source" => "Pixpalace")
    rescue => e
      logger.info"**** rescue #{e.inspect}"
      return "Erreur"
    end
    retour = JSON.parse(res.body)
    retour['_id']
  end

  def marek_request_build(ms_pic_id)
    params = []
    params << '9Pu0NkL41'
#    if ms_pic_id.to_s.length > 20
#      params << marek_decrypt(ms_pic_id)
#    else
      params << ms_pic_id
#    end
    params << current_user.title.server.name
    params << request.remote_ip
    params << current_user.title.name
    params << current_user.login
    marek_crypt(params.join('@@@'))
  end

  def marek_decrypt(mastr)
    tostr = ''
    offset = 0
    scan = true
    while scan
      skipChars = mastr[offset..offset].to_i
      offset += skipChars + 1
      if mastr[offset..offset] == '0'
        if mastr[offset+1..offset+1].to_i < 5
          tostr << '/'
        else
          tostr << '@'
        end
      elsif mastr[offset..offset] == '1'
        if mastr[offset+1..offset+1].to_i < 5
          tostr << ' '
        else
          tostr << '.'
        end
      else
        tostr << mastr[offset+1..offset+1]
      end
      offset += 2
      scan = false if mastr[offset].nil?
    end
    tostr.tr("A-Za-z", "N-ZA-Mn-za-m")
  end

  def marek_crypt(mastr)
    tostr = ''
    mastr.tr!("A-Za-z", "N-ZA-Mn-za-m")
    mastr.split('').each do |c|
      randnum = rand(2)+1
      tostr += randnum.to_s
      randnum.times do
        dol = rand(54); nextdummy = (dol>26) ? rand(9).to_s : (rand(26)+64).chr
        tostr += nextdummy
      end
      if c == '/'
        tostr += '0'+rand(4).to_s
      elsif c == '@'
        tostr += '0'+(rand(4)+5).to_s
      elsif c == ' '
        tostr += '1'+rand(4).to_s
      elsif c == '.'
        tostr += '1'+(rand(4)+5).to_s
      else
        tostr += (rand(8)+2).to_s+c
      end
    end
    tostr
  end

  def permitted_params
    params.require(:image).permit(:date_created, :headline, :description, :country, :city,
      :source, :creator, :rights, :credit, :subject, :instructions)
  end

end
