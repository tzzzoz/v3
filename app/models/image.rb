# encoding: utf-8

class Image < ActiveRecord::Base
include ThinkingSphinx::Scopes

  belongs_to  :provider
  has_many   :provider_response_to_requests, :dependent => :destroy
  has_many   :light_box_images, :dependent => :destroy
  has_many   :light_boxes, :through => :light_box_images
  has_many   :statistics, :dependent => :destroy

  validates :provider_id, :presence => true

  scope :order_by_provider_name, joins(:provider).order('providers.name, images.created_at ASC')
  scope :order_by_light_box_image_id_desc, -> { order('light_box_images.id DESC') }
  scope :order_by_light_box_position_desc, -> { order('light_box_images.position DESC') }

  #def self.searchable_fields
  #  [:title, :subject, :instructions, :creator, :city,
  #    :state, :country, :headline, :credit, :source, :file_name,
  #    :description, :reportage, :normalized_credit, :max_avail_width, :max_avail_height,
  #    :original_filename, :provider_comment, :restrictions, :rights, :category,
  #    :supplemental_category, :urgency, :authors_position, :transmission_reference, :caption_writer]
  #end

  def self.searchable_fields
      [:title, :subject, :instructions, :creator, :city, :country, :headline, :credit, :source, :file_name,
        :description, :reportage, :normalized_credit, :original_filename, :rights, :category]
    end

    
  def provider_name
    self.provider.name
  end

  def provider_logo
    #TODO: Sami put a generic logo when logo is missing
    "#{PICTURES_PATH}#{self.provider.logo}"
  end

  def hr_size
    "#{max_avail_width} x #{max_avail_height}"
  end

  def max_size
    #dpi = UserSession.find.user.title.dpi
    #dpi ||= '75'
    #dpi = dpi.to_i
    dpi = 75
    "#{(max_avail_width.to_i / dpi * 2.54).to_i} x #{(max_avail_height.to_i / dpi * 2.54).to_i} -- #{dpi} dpi"
  end

  def provider_conditions
    self.provider.provider_conditions
  end
  
  def localised_reception_date
    I18n.l(reception_date) unless reception_date.blank?
  end

  def localised_date_created
    # no time zone for the picture date metadata
    I18n.l(date_created) unless date_created.blank?
  end
  
  # Return medium_location or thumb_location value based on RSS_IMAGE_FORMAT value
  def rss_image_location
    __send__("#{RSS_IMAGE_FORMAT.to_s}_location")
  end

  def providers_authorizations
    user =  UserSession.find.user
    permissions_list =[]
    if user.is_superadmin?
      permissions_list = PermissionLabel.all
    else
      title_provider_group = TitleProviderGroup.find_by_provider_id_and_title_provider_group_name_id(self.provider_id, user.providers_group.id)
      permissions_list = title_provider_group.permission_labels if title_provider_group
    end

    permissions_list
  end

  def has_right(user,label)
    providers_authorizations.any?{|auth| auth.label == label}
  end

  def one_copyright_field?
    true unless [ creator, credit, source, rights, normalized_credit ].all? {|k| k.to_s.empty?}
  end

  def one_informational_field?
    true unless [ description, subject, headline ].all? {|k| k.to_s.empty?}
  end

  def delete_from_fs(*relative_path)
    relative_path.each do |f|
      begin
        File.delete("#{Rails.root}/public/#{f}")
      rescue Exception => e
        DELETE_LOG.error("#{Time.now.to_s} : error #{e} : while removing #{f}")
      end
    end
  end
  #----
  #TODO:All from rails doc: If you need to destroy or nullify associated records first, use the :dependent option on your associations.
  #TODO:Sami duplicate pictures which are in stats
  before_destroy do |im|
    # if im.light_box_images.blank?
    #reportages
    ReportagePhoto.where(:photo_ms_id => im.ms_image_id).each do |rp|
      rep = Reportage.find(rp.reportage_id)
      if rep.prem_photo == im.ms_image_id
        if rep.nb_photos < 2
          rep.destroy
        else
          ms_id = ReportagePhoto.where("reportage_id = #{rep.id} and rang > #{rp.rang}").first.photo_ms_id
          Reportage.update(rep.id, :prem_photo => ms_id, :nb_photos => (rep.nb_photos - 1))
        end
      else
        Reportage.update(rep.id, :nb_photos => (rep.nb_photos - 1))
      end
      rp.destroy
    end

    im_pathes = [im.medium_location, im.thumb_location]
    im_pathes << im.hires_location unless im.provider.input_dir.blank?
    im.delete_from_fs( *im_pathes)
    DELETE_LOG.info("#{Time.now.to_s} : deleting : #{im.file_name}")
    s_k = im.provider.string_key
    if s_k != "Sipa" && s_k != "Ap" && s_k != "Rex"
     MessageToMs::PutMessageRec.sendMessageRecord("DELETE_HR", im.ms_image_id, im.provider.string_key)
    end
    # else
    #   DELETE_LOG.info("#{Time.now.to_s} : #{im.file_name} will be destroyed when removed from #{im.light_box_images.count} viewers")
    # end
    #im.light_box_images.blank?
  end

  def delete_blank_images
    puts "******** Effacement photos blanches #{Time.now}"
    ic = 0
    Image.where(:ms_image_id => -1).find_each do |i|
      i.destroy
      ic += 1
    end
    puts "******** Fin : #{ic} effacements"
  end

  def self.delete_PA_only
    puts "******** Effacement photos PA_only #{Time.now}"
    ic = 0
    imgs = []
    purge_date = Time.now.midnight-1.month
    self.where('hires_location like ? and reception_date < ?', '%PA_only%', purge_date).find_each do |i|
        i.destroy
        ic += 1
    end
    puts "******** Fin : #{ic} effacements"
  end

  #verifies if passed images can be downloaded by user and then creates statistics
  def self.add_downloads_stats(options)
    options[:ids].each do |id|
      image = Image.find(id)
      unless image.nil? && !image.has_right(options[:user_id], options[:operation].to_s)
        image.statistics << Statistic.new(:operation_label_id => OperationLabel.find_by_label(options[:operation].to_s), :user_id => options[:user_id])
        image.save
      end
    end
  end

  private


  sphinx_scope(:by_date_created) {
    {:order => 'date_created DESC'}
  }

  sphinx_scope(:by_asc_created) {
    {:order => 'date_created ASC'}
  }

  sphinx_scope(:by_random) {
    {:order =>'RAND()'}
  }

  sphinx_scope(:by_n_per_agency) {
    {:group_by => 'provider_id', :group_function => :attr, :group_clause   => "@count desc"}
  }

  sphinx_scope(:by_relevance) {
    {}
  }

  sphinx_scope(:by_original_filename) {
    {:order =>'original_filename ASC'}
  }

  sphinx_scope(:by_asc_filename) {
    {:order =>'original_filename DESC'}
  }

  sphinx_scope(:by_reception_date) {
    {:order =>'reception_date DESC'}
  }

  sphinx_scope(:by_asc_date) {
    {:order =>'reception_date ASC'}
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
    end
  end
  
  def self.params_to_conditions(params)
    conditions = {}
    params.each do |k,v|
      conditions[k.to_sym] = Pixways::SearchesHelper.filter_keywords(v) if ( !v.blank? && Image.searchable_fields.include?(k.to_sym) )
    end
    conditions
  end

  def self.params_to_with(params)
    with = {}

    current = UserSession.find.user

    #if current.is_superadmin?
    authorized_providers = current.providers.collect{|e| e.id}
#    authorized_providers = UserSession.find.user.providers.collect{|e| e.id}
    #current_providers = params[:providers].blank? ? authorized_providers : params[:providers].keys.collect!{|e| e.to_i}
    providers_list = params[:providers].nil? || params[:providers].count == 0 ? authorized_providers : params[:providers].keys.collect!{|e| e.to_i}

    if params[:ratio] == 'all'
      # first to eval but nothing to do
    elsif params[:ratio] == 'square'
      with[:ratio] = 0.98..1.02
    elsif params[:ratio] == 'horizontal'
      with[:ratio] = 1.02..9999.0
    elsif params[:ratio] == 'vertical'
      with[:ratio] = 0.01..0.98
    elsif params[:ratio] == 'panoramic'
      with[:ratio] = 1.7..9999.0
    end

    if params[:media_typ] == 'all'
    #  # first to eval but nothing to do
    elsif params[:media_typ] == 'photos'
      with[:fonds] = 0
    elsif params[:media_typ] == 'videos'
      with[:fonds] = 1
    end

    with[:private_image]  = 0
    with[:content_error]  = 0

    with[:provider_id] = providers_list
    with[:updated_at] = Pixways::SearchesHelper.dates_to_range('',params[:search_time]) if params[:search_time]
    if params[:search_since] && params[:search_since] != 'all'
      with[:reception_date] = Image.since_conditions(params[:search_since])
    end
    with[:reception_date] = Pixways::SearchesHelper.dates_to_range(params[:reception_date_begin], params[:reception_date_end]) unless (params[:reception_date_begin].blank? && params[:reception_date_end].blank?)
    with[:date_created]   = Pixways::SearchesHelper.dates_to_range(params[:date_created_begin], params[:date_created_end])     unless (params[:date_created_begin].blank? && params[:date_created_end].blank?)

    with
  end
  
  def self.uploads_to_csv(ims)
    export = ""
    export.encode!('UTF-8')
    CSV(export, {:col_sep => ";"}) do |csv|
      csv << [
        "date",
        "nom fichier",
        "ville",
        "photographe",
        "titre",
        "crédit"
      ]
      ims.each do |i|
        csv << [I18n.l(i.updated_at), i.original_filename, i.provider.name, i.creator, i.normalized_credit]
      end
    end
    export
  end

  def self.export_to_csv(medias)
    export = ""
    export.encode!('UTF-8')
    CSV(export) do |csv|
      csv <<  Image.searchable_fields.collect{|key| I18n.t(key)}
      medias.each do |m|
       csv << Image.searchable_fields.collect{|k| m.send(k)}
      end
    end
    export
  end

end
