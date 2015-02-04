require 'RMagick'
require 'fileutils'
require 'net/ftp'
require "mysql2"

class Statistic < ActiveRecord::Base
include ThinkingSphinx::Scopes
  belongs_to :image
  belongs_to :user
  belongs_to :operation_label

  validates :image_id, :presence => true
  validates :user_id, :presence => true
  validates :operation_label_id, :presence => true

  def self.safe_save(options)
    options[:images_ids].each do |id|
      self.create(:user_id => options[:user_id], :image_id => id, :operation_label_id => options[:operation_id])
    end
  end


  def self.export_to_csv(stats)
    export = ""
    export.encode!('UTF-8')
    CSV(export, {:col_sep => ";"}) do |csv|
      csv << [
        "date",
        "telechargement",
        "titre",
        "utilisateur",
        "titre-userID",
        "agence",
        "nom fichier",
        "titre photo",
        "photographe",
        "legende"
      ]
      stats.each do |s|
        a = s.user.id
        user_status = ( s.user.nil?) ? ['', I18n.t(:deleted) ] : [s.user.title.name, s.user.login, s.user.title.name + "-#{a}"]
        im_status = (s.image.nil?) ? ['', I18n.t(:deleted) ] : [s.image.provider.name, s.image.original_filename]
        v = [s.image.headline, s.image.creator, s.image.description]
        csv << [I18n.l(s.created_at), s.operation_label.label] + user_status + im_status + v
      end
    end
    export
  end

  
  def provider
    image.provider
  end

  def title_id
    user.title_id
  end

  def operation_label_name
    I18n.t(self.operation_label.label.to_sym)
  end
  
  # --- dates --->
  def localised_created_at
    I18n.l(created_at.in_time_zone.to_time)
  end

  def localised_updated_at
    I18n.l(updated_at.in_time_zone.to_time)
  end


  def self.stats_downloads
    if Server.find_by_is_self(true).name == "webAgencesV2FR2"
      users = []
      users = User.where('title_id != 1 and roles_mask in (4,2)').collect{|u| u.id}
      time_range = (Time.now.midnight-7.day)..(Time.now.midnight)
      week_range =  "du #{I18n.l(Date.today-7.day)} au #{I18n.l(Date.today-1.day)}"
      prov_bd = {}
      prov_hd = {}
      prov_dem = {}
      title_hd = {}
      title_bd = {}
      title_dem = {}
      hide_hd = {}
      hide_bd = {}
      total_prov_hd = 0
      total_title_hd = 0
      total_prov_bd = 0
      total_prov_dem = 0
      total_title_bd = 0
      total_title_dem = 0
      total_hide_hd = 0
      total_hide_bd = 0

      Provider.where(:actif => true).order(:name).each do |prov|
        stats = Statistic.joins(:image).where(:user_id => users, :images => {:provider_id => prov.id}, :statistics => {:created_at => time_range}).order('created_at desc')
        statsbd = Statistic.joins(:image).where(:user_id => users, :images => {:provider_id => prov.id}, :statistics => {:created_at => time_range}, :operation_label_id => 1).count
        statshd = Statistic.joins(:image).where(:user_id => users, :images => {:provider_id => prov.id}, :statistics => {:created_at => time_range}, :operation_label_id => 2).count
        statsdem = Statistic.joins(:image).where(:user_id => users, :images => {:provider_id => prov.id}, :statistics => {:created_at => time_range}, :operation_label_id => 3).count

        prov_hd[prov.name] = statshd
        prov_bd[prov.name] = statsbd
        prov_dem[prov.name] = statsdem
        total_prov_hd += statshd
        total_prov_bd += statsbd
        total_prov_dem += statsdem
        mel = []
        mel = ProviderContact.where(:provider_id => prov.id, :receive_stat => true).collect{|pc| pc.email}
        date_range = "#{prov.name} du #{I18n.l(Date.today-7.day)} au #{I18n.l(Date.today-1.day)}"
        UserMailer.send_stats(stats, mel, date_range, statsbd, statshd, statsdem).deliver
      end
      UserMailer.pp_prov_stats(week_range, prov_hd, prov_bd, prov_dem, total_prov_hd, total_prov_bd, total_prov_dem).deliver
      Title.all.each do |title|
        users = User.where(:title_id => title.id).collect{|u| u.id unless (u.roles_mask == 16 || u.roles_mask == 8 || u.roles_mask == 1)}
        unless users.blank?
          t_statshd = Statistic.where(:user_id => users, :created_at => time_range, :operation_label_id => 2).count
          t_statsbd = Statistic.where(:user_id => users, :created_at => time_range, :operation_label_id => 1).count
          t_statsdem = Statistic.where(:user_id => users, :created_at => time_range, :operation_label_id => 3).count
          title_hd[title.name] = t_statshd
          title_bd[title.name] = t_statsbd
          title_dem[title.name] = t_statsdem
          total_title_hd += t_statshd
          total_title_bd += t_statsbd
        end

        users = User.where(:title_id => title.id).collect{|u| u.id if (u.roles_mask == 16 || u.roles_mask == 8 || u.roles_mask == 1)}
        unless users.blank?
          t_hidehd = Statistic.where(:user_id => users, :created_at => time_range, :operation_label_id => 2).count
          t_hidebd = Statistic.where(:user_id => users, :created_at => time_range, :operation_label_id => 1).count
          hide_hd[title.name] = t_hidehd
          hide_bd[title.name] = t_hidebd
          total_hide_hd += t_hidehd
          total_hide_bd += t_hidebd
        end

      end
      UserMailer.pp_title_stats(week_range, title_hd, title_bd, title_dem, total_title_hd, total_title_bd, total_title_dem).deliver
      UserMailer.pp_hide_stats(week_range, hide_hd, hide_bd, total_hide_hd, total_hide_bd).deliver
      Statistic.where(:created_at => time_range).find_each do |s|
           ArchStat.create(:user_id => s.user_id, :image_id => s.image_id, :created_at => s.created_at, :updated_at => s.updated_at, :operation_label_id => s.operation_label_id)
      end

    end
  end

  def self.send_to_pixtrak
    if Server.find_by_is_self(true).name == "webAgencesV2FR2"
      yesterday = (Time.now.midnight - 1.day)..(Time.now.end_of_day - 1.day)
      op_label = ["","BD","HD"]
      ic = 0
      puts "**** send to Pixtrak #{yesterday}"
      client = Mysql2::Client.new(:host => "192.168.203.1", :port => 3316, :username => "pixtrakk", :password => "p6trakk")
      client.query("use pixtrakk_production")

      Statistic.joins(:image => :provider).joins(:user).where(:statistics => {:created_at => yesterday}, :users => {:roles_mask => 4}).select('images.ms_image_id as ms_id, images.original_filename as ori_fn, users.title_id as tid, providers.string_key as stringkey, statistics.operation_label_id as opl, statistics.created_at as sdate').each do |s|
        ori = s.ori_fn.gsub("'",'_').gsub(" ","_")
        row =  client.query("INSERT INTO images_downloads (ms_picture_id, original_filename, publication_id, string_key, operation_label, downloaded_date, created_at) VALUES (#{s.ms_id}, '#{ori}', #{s.tid}, '#{s.stringkey}', '#{op_label[s.opl]}', '#{s.sdate}', NOW())")
        ic += 1
      end
      client.close
      puts "*** #{ic} stats envoyees"
    end
  end

  def self.send_bd_to_pixtrak
    threeday = (Time.now.midnight - 3.day)..(Time.now.end_of_day - 3.day)
    prov = []
    inDir = "PIXTRAKKCRAWLER"
    ic = 0
    puts "**** send to Pixtrak #{threeday}"
    Provider.where(:in_pixtrakk => true).collect{|p| prov << p.id}
    Statistic.joins(:image => :provider).joins(:user).where(:statistics => {:created_at => threeday}, :images => {:provider_id => prov}, :users => {:roles_mask => 4}).select('images.file_name as f_n, images.medium_location as med_loc').each do |s|
      file = "public#{s.med_loc}"
      ftp = Net::FTP.new("192.168.200.3")
      ftp.passive = true
      ftp.login("pixadmin_temp", "aip6de6i")
      ftp.chdir(inDir)
      ftp.putbinaryfile(file, s.f_n)
      ftp.close
      ic += 1
    end
    puts "*** #{ic} BD envoyes"
  end

  def self.params_to_conditions(params)
    conditions = {}
    params.each do |k,v|
      conditions[k.to_sym] = Pixways::SearchesHelper.filter_keywords(v) if ( !v.blank? && Image.searchable_fields.include?(k.to_sym) )
    end
    #conditions[:restrictions] = 'ANY'
    conditions
  end

  def self.params_to_with(params, provs, pays)
    with = {}
    authorized_providers = []
    authorized_titles = []

    if pays == 0
      authorized_titles = Title.all.collect{|t| t.id}
    else
      authorized_titles = Title.all.collect{|t| t.id if t.country_id == pays }
    end

    authorized_providers = provs

    providers_list = params[:providers].nil? || params[:providers].count == 0 ? authorized_providers : params[:providers].keys.collect!{|e| e.to_i}
    with[:provider_id] = providers_list

    if params[:mask] || !params[:hide_mask]
      with[:user_id] = User.where('roles_mask not in (16,8,1)').collect{|u| u.id}
    else
      with[:user_id] = User.all.collect{|u| u.id}
    end

    titles_list = params[:titles].nil? || params[:titles].count == 0 ? authorized_titles : authorized_titles & params[:titles].keys.collect!{|e| e.to_i}
    with[:title_id] = titles_list

    with[:updated_at] = Pixways::SearchesHelper.dates_to_range('',params[:search_time]) if params[:search_time]
    if params[:search_since] && params[:search_since] != 'all'
     with[:created_at] = Statistic.since_conditions(params[:search_since])
    end

    with[:created_at] = Pixways::SearchesHelper.dates_to_range(params[:reception_date_begin], params[:reception_date_end]) unless (params[:reception_date_begin].blank? && params[:reception_date_end].blank?)
    with[:operation_label_id] = params[:operation_label_id] if params[:operation_label_id] && params[:operation_label_id].to_i > 0
    with
  end

  private

  sphinx_scope(:by_original_filename) {
    {:order =>'original_filename ASC'}
  }

  sphinx_scope(:by_created_at) {
    {:order => 'created_at DESC'}
  }

  sphinx_scope(:by_operation_label_id) {
    {:order => 'operation_label_id ASC' }
  }

  sphinx_scope(:by_title_name) {
    {:order => 'title_name ASC' }
  }

  sphinx_scope(:by_user_login) {
    {:order => 'user_login ASC' }
  }

  sphinx_scope(:by_provider_name) {
    {:order => 'provider_name ASC' }
  }

  sphinx_scope(:by_creator) {
    {:order => 'creator ASC' }
  }

  sphinx_scope(:by_headline) {
    {:order => 'headline ASC' }
  }


  def self.since_conditions(since_txt)
    #to_i is automagicaly converting time, the only way to dispell magic I found is this
    current_time = Time.now
    current_time -= current_time.utc_offset
    upper_bound = 2145913199
    case since_txt
    when '10_minutes'
      (current_time - 10.minutes).to_i..upper_bound
    when '1_hour'
      (current_time - 1.hours).to_i..upper_bound
    when '1_day'
      (current_time - 1.day).to_i..upper_bound
    when '1_week'
      (current_time - 1.weeks).to_i..upper_bound
    when '1_month'
      (current_time - 1.months).to_i..upper_bound
    when '3_month'
      (current_time - 3.months).to_i..upper_bound
    when '1_year'
      (current_time - 1.year).to_i..upper_bound
    end
  end

  def self.is_there_stat(users)
    Statistic.where(:user_id => users).blank?
  end
  

end
