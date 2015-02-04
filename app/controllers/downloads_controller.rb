require 'zip'
require 'net/http'
require 'net/scp'

class DownloadsController < ApplicationController
layout "simple"

  def index
    if params[:offre]
      params[:ids] = []
      ReportagePhoto.where(:reportage_id => params[:offre].to_i).collect{|p| params[:ids] << Image.find_by_ms_image_id(p.photo_ms_id).id}
    end
    params[:ids].uniq!
    if params[:ids].blank?

    else
    provbd = []
    provbd = session[:provbd]
    provhd = []
    provhd = session[:provhd]
    u = current_user
    if params[:definition] == 'HD'
#      clic_save(2,u.id,0)
#      clic_save(2,u.id, params[:depage].to_i) unless params[:depage].nil?
      @aff_txt = ""
      ids_hdl = []
      ids_video = []
      ids_mov = []
      ids_dem = []
      ids_del = []
      params[:ids].each do |im|
        im_found = Image.find(im)
        if im_found.nil?
          ids_del << im
        elsif im_found.provider.local
          unless im_found.provider.input_dir.blank?
            @local_name = im_found.provider.name
            ids_hdl << im
            ids_del << im
          end
        elsif provhd[im_found.provider_id] != 1
          ids_dem << im
          ids_del << im
          @aff_txt += "#{im_found.original_filename} : demande envoyée à l'agence\n"
        elsif im_found.ms_id == "flv"
          ids_video << im
          ids_del << im
          @aff_txt += "#{im_found.original_filename} : demande envoyée à Akamedia\n"
        elsif im_found.ms_id == "mov"
          ids_mov << im
          ids_del << im
          @aff_txt += "#{im_found.original_filename} : demande envoyée\n"
        else
          @aff_txt += "#{im_found.original_filename} : photo haute définition téléchargée\n"
        end
      end
      ids_del.each do |i|
        params[:ids].delete(i)
      end

      if ids_hdl.empty?
        if conditions
          render :has_conditions, layout: nil
        else
          @dwn = marek_download_request(*params[:ids])
          render :index, layout: nil
          akamedia_hd_download(ids_video) unless ids_video.empty?
          mov_hd_download(ids_mov) unless ids_mov.empty?
          demande_download(ids_dem, 'HD') unless ids_dem.empty?
          params[:operation] = "HD"
          ids = @dwn.collect{|server| server.last['ids']}.flatten
          Statistic.safe_save(
            :images_ids => ids,
            :operation_id => OperationLabel.find_by_label('HD').id,
            :user_id => u.id
          ) unless ids.blank?
        end
      elsif params[:ids].empty?
        local_download(ids_hdl, 'HD', 'hires')
      else
        @ids_hd = params[:ids]
        @ids_lhd = ids_hdl
        render :double_download, :layout => nil
      end

    elsif params[:definition] == 'BD'
#      clic_save(2,u.id,1)
#      clic_save(2,u.id, params[:depage].to_i) unless params[:depage].nil?
      @aff_txt = ""
      ids_dem = []
      ids_video = []
      ids_del = []
      params[:ids].each do |im|
        im_found = Image.find(im)
        if im_found.nil?
          ids_del << im
        elsif provbd[im_found.provider_id] != 1
          ids_dem << im
          ids_del << im
          @aff_txt += "#{im_found.original_filename} : demande envoyée à l'agence\n"
        elsif im_found.ms_id == "flv" || im_found.ms_id == "mov"
          ids_video << im
          ids_del << im
          @aff_txt += "#{im_found.original_filename} : vidéo basse définition téléchargée\n"
        else
          @aff_txt += "#{im_found.original_filename} : photo basse définition téléchargée\n"
        end
      end
      ids_del.each do |i|
        params[:ids].delete(i)
      end

      local_download(params[:ids], 'BD', 'medium') unless params[:ids].empty?
      akamedia_bd_download(ids_video) unless ids_video.empty?
      demande_download(ids_dem, 'BD') unless ids_dem.empty?
    elsif params[:definition] == 'FLUX'
#      clic_save(2,u.id,2)

      flux_download(dwn_path, *params[:ids])

    elsif params[:definition] == 'LHD'
#      clic_save(2,u.id,3)
#      clic_save(2,u.id, params[:depage].to_i) unless params[:depage].nil?

      local_download(params[:ids], 'HD', 'hires')

    end
   end
  end

  def conditions
    return false if params[:condition_checked]
    prov = params[:ids].collect{ |i| Image.find(i).provider_id unless Image.find(i).provider.provider_conditions.blank? }
    @cond = {}
    session[:bnf_files] = []
    params[:ids].each do |i|
      p = Image.find(i).provider_id
      if Provider.find(p).string_key == 'Bnf'
        session[:bnf_files] << Image.find(i).original_filename
        prov << p
      end
      @cond[p]= [] unless @cond.key? p
      @cond[p] << i
    end
    prov.compact!
    return false if prov.blank?
    @prov = prov.uniq
    true
  end


  def bnf_form
    parameters = {
        :edition              => params[:edition],
        :title_edition        => params[:title_edition],
        :publication_edition  => params[:publication_edition],
        :presse               => params[:presse],
        :title_presse         => params[:title_presse],
        :num_presse           => params[:num_presse],
        :title_pub_presse     => params[:title_pub_presse],
        :num_pub_presse       => params[:num_pub_presse],
        :emission_tv          => params[:emission_tv],
        :diffusion_tv         => params[:diffusion_tv],
        :cinema               => params[:cinema],
        :film                 => params[:film],
        :diffusion_cinema     => params[:diffusion_cinema],
        :video                => params[:video],
        :illu_contenu_video   => params[:illu_contenu_video],
        :illu_contenant_video => params[:illu_contenant_video],
        :internet             => params[:internet],
        :publicitaire         => params[:publicitaire],
        :expo_salon           => params[:expo_salon],
        :other                => params[:other],
        :exemplaires          => params[:exemplaires],
        :diffusion            => params[:diffusion],
        :nclient              => params[:nclient],
        :legal_name           => params[:legal_name],
        :service              => params[:service],
        #:email               => params[:email],
        :adresse              => params[:adresse],
        :postal_code          => params[:postal_code],
        :city                 => params[:city],
        #:country              => params[:pays],
        #:tva                 => params[:tva],
        #:electronique         => params[:electronique],
        :bnf_files            => session[:bnf_files]
    }
    error=false
    session[:bnf_files].collect do |f|
      parameters[:bnf_files] = f
      Delayed::Job.enqueue ForwardBnfFormJob.new(parameters, current_user.login, current_user.title.name)
    end

    flash[:notice] =  I18n.t('download_conditions.mail_ok')
    render "error", layout: nil
  end

  def show
    respond_to do |format|
     format.xml { render :xml => "ok" }
    end
  end

  def bnf_mail
    provider= Provider.find_by_name('Bnf')
    mail_to = provider.provider_contacts.find_by_receive_requests(true).email
    user = User.find(params[:user_id].to_i)
    mail = UserMailer.send_bnf_form(mail_to, params[:parameters], user, params[:title_name]).deliver
    respond_to do |format|
      format.xml { render xml: "ok" }
      format.json { render json: "ok" }
    end
  end

  def user_demand
    imgs = {}
    prov = []
    im_prov = {}
    ms_id = []
    ms_id = params[:im_id].delete!("[]").split(",")
    ms_id.each do |i|
      img = Image.find_by_ms_image_id(i.to_i)
      im = img.original_filename
      p = img.provider_id
      f = img.thumb_location
      prov << p
      imgs[im] = f
      im_prov[p] = [] unless im_prov.key? p
      im_prov[p] << im
    end
    prov.compact!
    prov.uniq!
    user = User.find(params[:user_id].to_i)
    ope = params[:operation]
    prov.each do |p|
       mel = []
       mel = ProviderContact.where(:provider_id => p, :receive_demand => true).collect{|pc| pc.email}
       prov_name = Provider.find(p).name
       UserMailer.dw_provider(im_prov[p], imgs, prov_name, mel, user, ope).deliver
       UserMailer.dw_user(im_prov[p], imgs, user, prov_name, mel, ope).deliver
    end
    respond_to do |format|
      format.xml { render xml: "ok" }
      format.json { render json: "ok" }
    end
  end


  def aka_demand
    imgs = {}
    videos = []
    videos = params[:videos].split(";")
    videos.compact!
    videos.each do |i|
      imgs[i] = Image.find_by_original_filename(i).thumb_location unless i.blank?
    end
    user = User.find(params[:user_id].to_i)
    UserMailer.dw_akamedia(imgs, user).deliver
    UserMailer.dw_video_user(imgs, user).deliver
    respond_to do |format|
      format.xml { render :xml => "ok" }
      format.json { render json: "ok" }
    end
  end

  def akamedia_hd_download(ids)
    vids = ""
    ids.each do |i|
      err = Statistic.create(:user_id => current_user.id, :image_id => i, :operation_label_id => 1)
      vids += "#{Image.find(i).original_filename};"
    end
    Delayed::Job.enqueue ForwardAkaDemand.new(vids, current_user.login)
  end

  def mov_hd_download(ids)
    im_id = []
    ids.each do |i|
      err = Statistic.create(:user_id => current_user.id, :image_id => i, :operation_label_id => 4)
      img = Image.find(i)
      im_id << img.ms_image_id
      Delayed::Job.enqueue ForwardLrStatJob.new(img.file_name, img.provider_name, 4, current_user.login, current_user.title.name)
    end
    Delayed::Job.enqueue ForwardImgDemand.new(im_id, current_user.login, "video")
  end

  def akamedia_bd_download(ids)
    ids.each do |i|
      im = Image.find(i)
      err = Statistic.create(:user_id => current_user.id, :image_id => i, :operation_label_id => 2)
      Delayed::Job.enqueue ForwardLrStatJob.new(im.file_name, im.provider_name, 2, current_user.login, current_user.title.name)
      fic = im.original_filename.gsub(".jpg",".#{im.ms_id}")
      t = Tempfile.new("video_#{i}")
      t_video = t.path+".#{im.ms_id}"
      open(t_video, "wb") do |file|
        file << open(im.hires_location).read
      end
      send_file t_video, :type => 'application/#{im.ms_id}', :disposition => 'attachment', :filename => fic
      t.close
      t.unlink
    end
  end

  def demande_download(ids, operation)
    im_id = []
    ids.each do |i|
      err = Statistic.create(:user_id => current_user.id, :image_id => i, :operation_label_id => 3)
      img = Image.find(i)
      im_id << img.ms_image_id
      Delayed::Job.enqueue ForwardLrStatJob.new(img.file_name, img.provider_name, 3, current_user.login, current_user.title.name)
    end
    Delayed::Job.enqueue ForwardImgDemand.new(im_id, current_user.login, operation)
  end

  def local_download(ids, operation, location)
    if ids.length > 1
      h = Time.now
      j = "#{h.year.to_s}#{h.month.to_s}#{h.day.to_s}#{h.hour.to_s}#{h.min.to_s}#{h.sec.to_s}"
      t = Tempfile.new("#{request.remote_ip}")
      t_zip = t.path+".zip"
      Zip::File.open(t_zip, Zip::File::CREATE) do |zipfile|
        ids.each do |id|
          extract = Image.find(id.to_i)
          cur_file = extract.send("#{location}_location")
          zipfile.add("#{File.basename(cur_file)}", "public#{cur_file}")
          Delayed::Job.enqueue ForwardLrStatJob.new(extract.file_name, extract.provider_name, 1, current_user.login, current_user.title.name) unless Provider.find(extract.provider_id).local?
          Statistic.create(:image_id => id, :user_id => current_user.id, :operation_label_id => OperationLabel.find_by_label(operation).id)
        end
      end
      send_file t_zip, :type => 'application/zip', :disposition => 'attachment', :filename => "#{Server.find_by_is_self(true).name}_download_#{j}.zip"
      t.close
      t.unlink
    else
      extract = Image.find(ids.first.to_i)
      operation_id = OperationLabel.find_by_label(operation)
      cur_file = extract.send("#{location}_location")
      send_file "public#{cur_file}", :disposition => 'attachment'
      extract.statistics << Statistic.new(:operation_label_id => operation_id.id, :user_id => current_user.id) if operation_id
      extract.save
      Delayed::Job.enqueue ForwardLrStatJob.new(extract.file_name, extract.provider_name, operation_id.id, current_user.login, current_user.title.name) unless Provider.find(extract.provider_id).local?
      @aff_txt += "Photo basse définition téléchargée : #{extract.original_filename}\n"
    end
  end



  private

  def safe_directory_name_escape(directory_name)
    Iconv.new('US-ASCII//TRANSLIT', 'utf-8').iconv(directory_name).gsub("'", '').gsub(/[^A-z]/, '_')
  end

  def flux_download(dwn_path, *images_ids)
    operation = 'HD'
    images_ids.each do |id|
      extract = Image.find(id.to_i)
      next if extract.nil? || provhd[extract.provider_id] != 1

      if MS.include? extract.ms_id
        requ = marek_request_build(extract.ms_picture_id)
        uri = URI("http://ftp.pixpalace.com/cgi-bin/download_pixpalace.zip")
        res = Net::HTTP.post_form(uri, 'from' => requ)
        tempfile = Tempfile.new("wb")
        tempfile.binmode
        tempfile.write(res.body)
        tempfile.rewind
        pict = "public/flux/#{extract.file_name}"
        File.open(pict, "wb"){ |f| f.write(tempfile.read) }
        tempfile.close
        tempfile.unlink
        Net::SCP.upload!("192.168.0.12", "v2",
          pict, "#{dwn_path}#{extract.file_name}",
          :ssh => { :password => "qc28ng77" })
      else
        FileUtils::cp( "public#{extract.hires_location}", dwn_path )
      end
      Statistic.create(:image_id => extract.id, :operation_label_id => OperationLabel.find_by_label(operation).id, :user_id => current_user.id)
    end
  end

  def marek_download_request(*images_ids)
    dwn = {}
    images_ids.each do |id|
      extract = Image.find(id.to_i)
      next if extract.nil? || !extract.has_right(current_user,'HD')

      if MS.include? extract.ms_id
        serv = MS[extract.ms_id]
        serv_ms = extract.ms_id
        serv_cgi = "http://#{serv}/cgi-bin/download_pixpalace.zip"
        requ = marek_request_build(extract.ms_picture_id)
        unless dwn.key? serv_ms
          dwn[serv_ms]  = {}
          dwn[serv_ms]['ids'] = []
          dwn[serv_ms]['urls'] = {}
        end
        dwn[serv_ms]['ids'] << id
        dwn[serv_ms]['urls'][serv_cgi] = [] unless dwn[serv_ms]['urls'].key? serv_cgi
        dwn[serv_ms]['urls'][serv_cgi] << "http://#{serv}/cgi-bin/download_single.zip?from=#{requ}"

      elsif extract.ms_id == Server.find_by_is_self(true).name
        serv_ms = extract.ms_id
        unless dwn.key? serv_ms
          dwn[serv_ms]  = {}
          dwn[serv_ms]['ids'] = []
          dwn[serv_ms]['urls'] = {}
        end
        unless dwn[serv_ms]['urls'].key? 'LOCAL'
          dwn[serv_ms]['urls']['LOCAL'] = []
          dwn[serv_ms]['urls']['LOCAL'][0] = '/downloads?definition=LHD'
        end
        dwn[serv_ms]['urls']['LOCAL'][0] += "&amp;ids[]=#{id}"
      end
    end
    dwn
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

end
