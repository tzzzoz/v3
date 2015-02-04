# encoding: utf-8

class Feed

  def initialize(current)
    @current = current
  end

  private

  def process

    yield

    base_name = File.basename(@current.path)
    #raise PpException::NoReceptionDate if @current.meta[:reception_date].blank?
    reception_date = @current.meta[:reception_date].split(' ')[0]
    @current.meta[:provider_id] = @current.provider.id
    @current.meta[:file_name] = base_name
    @current.meta[:thumb_location] = "/images/photos/#{@current.provider.string_key}/#{reception_date}/thumbs/#{base_name}"
    @current.meta[:medium_location] = "/images/photos/#{@current.provider.string_key}/#{reception_date}/med/#{base_name}"
    @current.meta[:ratio] =  @current.meta[:max_avail_width].to_f / @current.meta[:max_avail_height].to_f
    copyright = Provider.find(@current.meta[:provider_id]).copyright_rule
    @current.meta.each{ |k,v| copyright.gsub!('#{:'+k.to_s+'}',v.to_s)}
    copyright.gsub!(/#\{:(.+)\}/,'')
    copyright = "© #{copyright}" unless copyright[0..0] == '©' || copyright.blank?
    @current.meta[:normalized_credit] = copyright
  end

  def write_files
    if @current.feed == :pixpalace
      write_thumb
      copy_or_move_med(@current.folder)

    elsif @current.feed == :local
      write_thumb
      write_med
      copy_or_move_high(@current.folder)

    elsif @current.feed == :pixtrakk
      write_thumb
      copy_or_move_pt_med(@current.folder)

    else
      raise  PpException::UnknownFeedType
    end
  end

  def save_on_fs_and_db
    im = ::Image.new(@current.meta)
    check_content(im)
    im.save!
    write_files
  end


  def seek_then_replace
    im_tst = ::Image.where(:original_filename => @current.meta[:original_filename], :provider_id => @current.meta[:provider_id]).first
    im_msid = ::Image.find_by_ms_image_id(@current.meta[:ms_image_id])
    if @current.meta[:update_msid] == "new"
      # f_name = @current.meta[:reception_date].split(' ')[0]
      # fic = "photos_#{f_name}"
      # File.open("/var/www/v2/current/public/images/photos/#{fic}", "a") do |file|
      #   file.write "#{@current.meta[:ms_image_id]},#{@current.provider.string_key},#{@current.meta[:file_name]},#{@current.meta[:reception_date]},#{@current.meta[:medium_location]},#{Time.now}\n"
      # end

      if im_tst.nil?
        unless im_msid.nil?
          LOG.debug("New Image #{@current.meta[:file_name]} has known ms_id (#{im_msid.file_name}) => #{im_msid.file_name} is deleted")
          delete_photo(im_msid)
        end
        create_photo
      else
        unless im_msid.nil?
          if im_tst.ms_image_id == im_msid.ms_image_id
            LOG.debug("New Image #{@current.meta[:file_name]} already exists with same ms_id (#{im_tst.ms_image_id}) and is replaced")
          else
            LOG.debug("New Image #{@current.meta[:file_name]} already exists with different ms_id (#{im_tst.ms_image_id}) =>  #{im_msid.file_name} is deleted - #{im_tst.file_name} is replaced")
            delete_photo(im_msid)
          end
        end
        @current.meta[:reception_date] = im_tst[:reception_date]
        update_photo(im_tst)
      end
    elsif @current.meta[:update_msid] == "update"
      if im_tst.nil?
        if im_msid.nil?
          LOG.debug("update Image #{@current.meta[:file_name]} not exists and is created")
        else
          LOG.debug("update Image #{@current.meta[:file_name]} not exists but ms_id exists. #{@current.meta[:file_name]} is created and #{im_msid.file_name} is deleted")
          delete_photo(im_msid)
        end
        create_photo
      else
        unless im_msid.nil?
          if im_tst.ms_image_id == im_msid.ms_image_id
            LOG.debug("update Image #{@current.meta[:file_name]} exists with same ms_id (#{im_tst.ms_image_id}) and is replaced")
          else
            LOG.debug("update Image #{@current.meta[:file_name]} exists with different ms_id (#{im_tst.ms_image_id}) =>  #{im_msid.file_name} is deleted - #{im_tst.file_name} is replaced")
            delete_photo(im_msid)
          end
        end
        @current.meta[:reception_date] = im_tst[:reception_date]
        update_photo(im_tst)
      end
    else
#      raise PpException::MsImageIdProblem
      im_old = ::Image.find_by_ms_image_id(@current.meta[:ms_image_id])
      if im_old.nil?
        im = ::Image.new(@current.meta)
        check_content(im)
        im.save!
        save_reportage(im) unless im.reportage.blank?
      else
        test_reception_date = @current.meta[:reception_date].to_time
        test_reception_date = test_reception_date.advance(:years => 2000) if (test_reception_date.year() < 2000)
        if test_reception_date >= im_old[:reception_date].to_time
          @current.meta[:reception_date] = im_old[:reception_date]
          im_old.update_attributes(@current.meta)
          im_old.update_attributes(:content_error => 0)
          im_old.update_attributes(:instructions => nil) if @current.meta[:instructions].blank?
          check_content(im_old)
          im_old.save!
          LOG.debug("#{@current.meta[:file_name]} replaced")
        else
          LOG.warn("old picture #{im_old[:reception_date].to_time} more recent than new #{@current.meta[:reception_date].to_time}")
          raise PpException::OlderServerTimeForUpdate
        end
      end
    end
    if @current.meta[:exclusivity] == "yes"
      @current.meta[:exclusivity] = 1
    else
      @current.meta[:exclusivity] = 0
    end
    write_files
  end

  def pt_seek_then_replace
    if @current.meta[:ms_image_id] == -1
        im_old = ::Image.find_by_file_name(@current.meta[:file_name])
        @current.meta[:original_filename] = @current.meta[:file_name]
        @current.meta[:headline] = nil
        @current.meta[:credit] = nil
        @current.meta[:description] = nil
        @current.meta[:creator] = nil
        @current.meta[:subject] = nil
        @current.meta[:instructions] = nil
        @current.meta[:title] = nil
    else
        im_old = ::Image.find_by_ms_image_id(@current.meta[:ms_image_id])
    end
    if im_old.nil?
      im = ::Image.new(@current.meta)
      check_saif(im) if @current.provider.id == 156
      im.save!
    else
      test_reception_date = @current.meta[:reception_date]
      #test_reception_date = test_reception_date.advance(:years => 2000) if (test_reception_date.year() < 2000)
      #if test_reception_date >= im_old[:reception_date].to_time
        @current.meta[:reception_date] = im_old[:reception_date]
        im_old.update_attributes(@current.meta)
        im_old.update_attributes(:content_error => 0)
        im_old.save!
        @current.meta[:reception_date] = test_reception_date
        LOG.debug("#{@current.meta[:file_name]} replaced")
      #else
      #  LOG.warn("old picture #{im_old[:reception_date].to_time} more recent than new #{@current.meta[:reception_date].to_time}")
      #  raise PpException::OlderServerTimeForUpdate
      #end
    end
    write_files
  end

  def local_seek_then_replace
    im_old = ::Image.where(:original_filename => @current.meta[:original_filename],:provider_id => @current.meta[:provider_id], :ms_id => @current.meta[:ms_id]).first
    if im_old.nil?
      im = ::Image.new(@current.meta)
      #check_content(im)
      im.save!
    else
      test_reception_date = @current.meta[:reception_date].to_time
      if test_reception_date >= im_old[:reception_date].to_time
        @current.meta[:reception_date] = im_old[:reception_date]
        im_old.update_attributes(@current.meta)
        check_content(im_old)
        LOG.debug("#{@current.meta[:file_name]} replaced")
      else
        LOG.warn("old picture #{im_old[:reception_date].to_time} more recent than new #{@current.meta[:reception_date].to_time}")
        raise PpException::OlderServerTimeForUpdate
      end
    end
    write_files
  end

  def check_saif(media)
    if media.creator.blank?
      LOG.warn "Saif photographe vide : #{File.basename(@current.path)}"
      raise PpException::SaifEmptyPhotographe
    end
  end

  def check_content(media)
    unless media.one_copyright_field?
      media.content_error = true
      LOG.warn "meta incomplete : no copyright for #{File.basename(@current.path)}"
    end

    unless media.one_informational_field?
      media.content_error = true
      LOG.warn "meta incomplete : no infos for #{File.basename(@current.path)}"
    end
    unless media.reception_date.year() > 2000
      media.reception_date = media.reception_date.change(year: Time.now.year)
    end
  end

  def save_reportage(img)
    prov_sk = ::Provider.find(img.provider_id).string_key
    rep = ::Reportage.where(:string_key => prov_sk, :no_reportage => img.reportage).first
    if rep.nil?
      date_cr = img.date_created
      date_cr = Time.now if date_cr.blank?
      rep = ::Reportage.create(:no_reportage => img.reportage, :string_key => prov_sk, :nb_photos => 1, :prem_photo => img.ms_image_id, :rep_titre => img.headline, :rep_date => date_cr, :signatur => img.normalized_credit)
      ::ReportagePhoto.create(:reportage_id => rep.id, :photo_ms_id => img.ms_image_id, :rang => 0)
      LOG.warn "Creation reportage : #{img.file_name}"
    else
      if ::ReportagePhoto.where(:reportage_id => rep.id, :photo_ms_id => img.ms_image_id).empty?
        test_rep = ::ReportagePhoto.where(:reportage_id => rep.id).order('rang DESC').limit(1).first
        if test_rep.nil?
          ::Reportage.update(rep.id, :nb_photos => 1)
          ::ReportagePhoto.create(:reportage_id => rep.id, :photo_ms_id => img.ms_image_id, :rang => 0)
        else
          rang = test_rep.rang
          ::Reportage.update(rep.id, :nb_photos => rep.nb_photos+1)
          ::ReportagePhoto.create(:reportage_id => rep.id, :photo_ms_id => img.ms_image_id, :rang => rang+1)
        end
        LOG.warn "Photo ajoutee #{img.file_name} Reportage #{img.reportage}"
      end
    end
  end

  def remove_update_msid
    @current.meta.delete_if {|key, value| key == "update_msid".to_sym }
  end

  def create_photo
    remove_update_msid
    im = ::Image.new(@current.meta)
    check_content(im)
    im.save!
    save_reportage(im) unless im.reportage.blank?
  end

  def delete_photo(img)
    im = ::Image.find(img)
    im.destroy
  end

  def update_photo(img)
    remove_update_msid
    img.update_attributes(@current.meta)
    img.update_attributes(:content_error => 0)
    img.update_attributes(:instructions => nil) if @current.meta[:instructions].blank?
    check_content(img)
    img.save!
  end

  def write_thumb
    FileUtils::makedirs(PROCESSOR_CONFIG[:paths][:out]+File.dirname(@current.meta[:thumb_location]))
    thumb = @current.media.fit_square(320)
    thumb.write(PROCESSOR_CONFIG[:paths][:out]+@current.meta[:thumb_location]){ self.quality = 80 }
  end

  def write_med
    FileUtils::makedirs(PROCESSOR_CONFIG[:paths][:out]+File.dirname(@current.meta[:medium_location]))
    med = @current.media.fit_square(600)
    med.write(PROCESSOR_CONFIG[:paths][:out]+@current.meta[:medium_location]){ self.quality = 80 }
  end

  def copy_or_move_med(folder_type)
    FileUtils::makedirs(PROCESSOR_CONFIG[:paths][:out]+File.dirname(@current.meta[:medium_location]))
    if folder_type == :hotfolder
      FileUtils.mv(@current.path, PROCESSOR_CONFIG[:paths][:out]+File.dirname(@current.meta[:medium_location]))
    elsif folder_type == :coldfolder
      FileUtils.cp(@current.path, PROCESSOR_CONFIG[:paths][:out]+File.dirname(@current.meta[:medium_location]))
    else
      raise  PpException::UnknownFolderProcessing
    end
  end

  def copy_or_move_pt_med(folder_type)
    FileUtils::makedirs(PROCESSOR_CONFIG[:paths][:out]+File.dirname(@current.meta[:medium_location]))
    if folder_type == :hotfolder
      File.rename(@current.path, PROCESSOR_CONFIG[:paths][:out]+File.dirname(@current.meta[:medium_location]))
    elsif folder_type == :coldfolder
      FileUtils.cp(@current.path, PROCESSOR_CONFIG[:paths][:out]+File.dirname(@current.meta[:medium_location]))
    else
      raise  PpException::UnknownFolderProcessing
    end
  end

  def copy_or_move_high(folder_type)
    FileUtils::makedirs(PROCESSOR_CONFIG[:paths][:out]+File.dirname(@current.meta[:hires_location]))
    if folder_type == :hotfolder
      FileUtils.mv(@current.path, PROCESSOR_CONFIG[:paths][:out]+File.dirname(@current.meta[:hires_location]))
    elsif folder_type == :coldfolder
      FileUtils.cp(@current.path, PROCESSOR_CONFIG[:paths][:out]+File.dirname(@current.meta[:hires_location]))
    else
      raise  PpException::UnknownFolderProcessing
    end
  end

end
