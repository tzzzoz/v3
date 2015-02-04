RMAGICK_BYPASS_VERSION_TEST = true
require 'csv'
require 'RMagick'
require 'fileutils'
require 'net/ftp'
require "mysql2"

class Provider < ActiveRecord::Base
  has_many :title_provider_groups, :dependent => :destroy
  has_many :title_provider_group_names, :through => :title_provider_groups
  has_many :search_provider_groups
  has_many :search_provider_group_names, :through => :search_provider_groups
  has_many :selected_providers_for_requests
  has_many :request_to_providers, :through => :selected_providers_for_requests
  has_many :images
  has_many :recent_images, -> { order('rand()').limit(10).where(content_error: false) }, :class_name => "Image"
  has_many :authorized_countries
  has_many :countries, :through => :authorized_countries
  has_many :provider_contacts, :dependent => :destroy
  accepts_nested_attributes_for :provider_contacts, :reject_if => :all_blank, :allow_destroy => true
  #accepts_nested_attributes_for :authorized_countries, :reject_if => nil, :allow_destroy => true


  mount_uploader :logo, LogoUploader
  mount_uploader :pdf, PdfUploader
  mount_uploader :formu, FormuUploader

  validates :name, :presence => true, :uniqueness => { :case_sensitive => false }
  validates :string_key, :presence => true, :uniqueness => { :case_sensitive => false }
  validates :copyright_rule, :presence => true
  validates :country, :presence => true

  before_destroy do |prov|
    Statistic.joins(:image).where(:images => {:provider_id => prov.id}).collect{|s| s.destroy}
    Reportage.where(:string_key => prov.string_key).collect{|r| r.destroy}
    prov.images.find_each{|i| i.destroy}
  end

  after_destroy do
    Provider.delete_cache_class_variables([:@@_by_string_key_length, :@@_by_input_dir])
  end

  after_save do
    Provider.delete_cache_class_variables([:@@_by_string_key_length, :@@_by_input_dir])
  end

  def self.delete_cache_class_variables(c_vars)
    (self.class_variables & c_vars).each{|c| self.remove_class_variable c}
  end

  def self.get_from_file_name(file_name)
    f = File.basename(file_name).upcase
    @@_by_string_key_length ||= order("LENGTH(string_key) DESC").all
    @@_by_string_key_length.detect {|prov| f =~ Regexp.new(/^#{prov.string_key.upcase}/)}
  end

  def self.get_from_input_dir(input_dir)
    ( @@_by_input_dir ||= {} )[input_dir] ||= find_by_input_dir(input_dir)
  end

  def self.find_my_provs(provs)
    l_prov = []
    provs.each_index{|i| l_prov << i if provs[i] == 1}
    Provider.where(:id => l_prov).order(:name)
  end

  def self.stats_3months
    if (Server.find_by_is_self(true).name == "webAgencesV2FR2")
      users = User.where('roles_mask in (2,4)').collect{|u| u.id}
      time_range = "2013-10-01 00:00".."2013-12-31 23:59"
      month_range = "2013-12-01 00:00".."2013-12-31 23:59"
      week_range =  "du 1er au 31 decembre 2013"
      mois_encours = Time.now.month.to_i
      mois_encours = mois_encours-1
      prov_hd = {}
      prov_1mois = {}
      total_prov_hd = 0
      total_prov_1mois = 0

      Provider.where(:actif => true).order(:pp_name).each do |prov|
        statshd = Statistic.joins(:image).where(:images => {:provider_id => prov.id}, :statistics => {:user_id => users, :created_at => time_range}).count
        prov_hd[prov.pp_name] = statshd
        total_prov_hd += statshd

        statsm = Statistic.joins(:image).where(:user_id => users, :images => {:provider_id => prov.id}, :statistics => {:created_at => month_range}).count
        prov_1mois[prov.pp_name] = statsm
        total_prov_1mois += statsm
      end
      UserMailer.prov_3monthsstats(week_range, mois_encours, prov_hd, total_prov_hd, prov_1mois, total_prov_1mois).deliver
    end
  end

  def self.send_yas
    if Server.find_by_is_self(true).name == 'webAgencesV2FR2'
      total_photos = 0
      prov = {}
      Provider.where(:actif => true).order(:name).each do |p|
        nb_photos = Image.where(:provider_id => p.id, :content_error => false).count
        prov[p.name] = nb_photos
        total_photos += nb_photos
      end

      UserMailer.send_yas(prov, total_photos).deliver
    end
  end

  def self.check_controls
    ddeb = Time.now.midnight - 1.day
    dfin = Time.now.end_of_day - 1.day
    client = Mysql2::Client.new(:host => "192.168.203.1", :username => "mspixfr", :password => "isa1956")
    client.query("use main_server")

    self.where(:actif => true).each do |p|
      prov = {}
      prova = {}
      client.query("SELECT distinct mtpa_id, mtpa_param3, mtpa_param4 FROM MessageToPA where mtpa_done = 0 and mtpa_param1 = '#{p.string_key}' and mtpa_param5 in ('0', '1') and mtpa_message='1' and mtpa_created_at > '#{ddeb}' and mtpa_created_at < '#{dfin}' and mtpa_param3 != 11 order by mtpa_created_at DESC").each do |row|
        prov[row["mtpa_param4"]] = row["mtpa_param3"].to_i
      end
      client.query("SELECT distinct mtpa_id, mtpa_param3, mtpa_param4 FROM MessageToPA where mtpa_done = 0 and mtpa_param1 = '#{p.string_key}' and mtpa_param5 in ('0', '1') and mtpa_message='1' and mtpa_created_at > '#{ddeb}' and mtpa_created_at < '#{dfin}' and mtpa_param3 = 11 order by mtpa_created_at DESC").each do |row|
        prova[row["mtpa_param4"]] = row["mtpa_param3"].to_i
      end
      unless prov.empty? && prova.empty?
        mel = ProviderContact.where(:provider_id => p.id, :receive_errors => true).collect{|pc| pc.email}
        #mel = "patrick.lamotte@pixpalace.com"
        UserMailer.ch_controls(mel, p.name, prov, prova).deliver
      end
    end
    client.close
  end

  def self.destroy_old_images
    self.where('days_keep IS NOT NULL').each do |p|
      search_str = 'provider_id = ? AND updated_at < ? AND private_image = false'
      search_str += ' AND erasable = true' if p.days_keep_per_picture
      Image.find_each(:conditions => [search_str, p.id, Time.now.utc - p.days_keep.days]) {|i| i.destroy }
    end
  end

  def self.delete_old_images
    self.where('days_keep IS NOT NULL').each do |p|
      #search_str = 'provider_id = ? AND updated_at < ? AND private_image = false AND fonds = 0'
      search_str = 'provider_id = ? AND reception_date < ? AND content_error = false '
      search_str += ' AND erasable = true ' if p.days_keep_per_picture
      if Server.find_by_is_self(true).name == 'webAgencesV2FR2'
        inDir = "pixpalaceplus"
        imgs = []
        puts "***** Agence #{p.name}"
        Image.where(search_str, p.id, Time.now.utc - p.days_keep.days).find_each do |i|
          imgs << i
          file = "public#{i.medium_location}"
          ftp = Net::FTP.new("192.168.200.3")
          ftp.passive = true
          ftp.login("pixadmin_temp", "aip6de6i")
          ftp.chdir(inDir)
          ftp.putbinaryfile(file, i.file_name)
          ftp.close
        end
        puts "***** Nb photos a effacer #{imgs.count}"

        inDir = "pixpalaceplus2"

        imgs.each do |i|
          file = "public#{i.medium_location}"
          ftp = Net::FTP.new("192.168.200.3")
          ftp.passive = true
          ftp.login("pixadmin_temp", "aip6de6i")
          ftp.chdir(inDir)
          ftp.putbinaryfile(file, i.file_name)
          ftp.close

          if Statistic.where(:image_id => i.id).blank?
            i.destroy
          else
            i.content_error=true
            i.save
          end
        end
        puts "***** FIN ************"
      else
        Image.where(search_str, p.id, Time.now.utc - p.days_keep.days).find_each do |i|
          if Statistic.where(:image_id => i.id).blank?
            i.destroy
          else
            i.content_error=true
            i.save
          end
        end
      end
    end
  end

  def self.delete_toomany_images
    self.where('toomany_limit > 0').each do |p|
      nb_photos = Image.where(:provider_id => p.id, :content_error => 0).count.to_i
      if p.toomany_limit < nb_photos
        imgs = []
        Image.where(:provider_id => p.id, :content_error => 0).order(:updated_at).limit(nb_photos - p.toomany_limit).find_each do |i|
          imgs << i
        end
        puts "***** Agence #{p.name} Nb photos a effacer #{imgs.count}"
        if Server.find_by_is_self(true).name == 'webAgencesV2FR2'
          inDir = "pixpalaceplus"
          imgs.each do |i|
            file = "public#{i.medium_location}"
            ftp = Net::FTP.new("192.168.200.3")
            ftp.passive = true
            ftp.login("pixadmin_temp", "aip6de6i")
            ftp.chdir(inDir)
            ftp.putbinaryfile(file, i.file_name)
            ftp.close
          end

          inDir = "pixpalaceplus2"
          imgs.each do |i|
            file = "public#{i.medium_location}"
            ftp = Net::FTP.new("192.168.200.3")
            ftp.passive = true
            ftp.login("pixadmin_temp", "aip6de6i")
            ftp.chdir(inDir)
            ftp.putbinaryfile(file, i.file_name)
            ftp.close

            if Statistic.where(:image_id => i.id).blank?
              i.destroy
            else
              i.content_error=true
              i.save
            end
          end
          puts "***** FIN ************"

        elsif Server.find_by_is_self(true).name == 'PTREF02' || Server.find_by_is_self(true).name == 'PTREF01'
          imgs.each do |i|
            FileUtils.cp("/var/spool/media/photoblanche.jpg", "/var/spool/media/TODELETE/#{p.string_key}.#{i.original_filename}")
          end
        else
          imgs.each do |i|
            if Statistic.where(:image_id => i.id).blank?
              i.destroy
            else
              i.content_error=true
              i.save
            end
          end
        end
      end
    end
  end
  ### Admin ##

  def add_authorization_to_group(permission_label_id, group_id)
    return false unless membership = title_provider_groups.find_by_title_provider_group_name_id(group_id)
    membership.authorizations << Authorization.new(:permission_label_id => permission_label_id)
  end

  def withdraw_authorization(permission_label_id, group_name_id)
    auth = Authorization.find_by_title_provider_group_id_and_permission_label_id(title_provider_groups.find_by_title_provider_group_name_id(group_name_id), permission_label_id)
    auth.destroy if auth
  end

  def withdraw_authorization_by_permission_name(permission_label, group_name)
    permission = PermissionLabel.find_by_label(permission_label)
    group = TitleProviderGroupName.find_by_name(group_name)
    if(permission && group)
      withdraw_authorization(permission.id, group.id)
    end
  end

  def add_logo(filename, file)
    begin
      ext = filename.split('.')[-1].downcase
      raise 'not a jpeg' if ext.match(/jpg|jpeg|jpe/).nil?
      logo = Magick::Image.read(file).first.resize_to_fit(140, 45)
      logo.write("#{Rails.root}/public/images/providers/#{string_key}.jpg")
      update_attributes({:logo => "#{string_key}.jpg"})
      true
    rescue
      false
    end
  end

  def self.export_to_csv(providers)
    export = ""
    export.encode!('UTF-8')
    CSV(export, {:col_sep => ";"}) do |csv|
      keys = [ :first_name, :last_name, :email, :phone, :fax]
      additionnal_keys = [I18n.t(:site), I18n.t(:address)]
      csv << [I18n.t(:provider)] + keys.collect {|key| I18n.t(key)} + additionnal_keys
      providers.each do |p|
        prov_line = [p.address, p.zip_code, p.city, p.country].compact.join(", ")
        p.provider_contacts.each do |contact|
          contact_data = []
          contact_data << p.name
          keys.each {|k| contact_data << contact.send(k)}
          contact_data << p.site << prov_line
          csv << contact_data
        end
      end
    end
    export
  end

  private

end
