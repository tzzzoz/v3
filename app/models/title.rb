class Title < ActiveRecord::Base

  TITLE_VISIBLE   = ['admin.title.do_not_display','admin.title.test','admin.title.customer', 'admin.title.partner']
  TITLE_TYPE      = ['admin.title.magazine','admin.title.book_publisher','admin.title.corporate','admin.title.PQN','admin.title.university','admin.title.communication_agency','admin.title.press_com_agency','admin.title.website','admin.title.independant_icono']

  has_many :users, :dependent => :nullify
  has_many :light_boxes, :dependent => :destroy
  belongs_to :title_provider_group_name
  
  belongs_to :server
  belongs_to :country

  validates :server, :associated => true
  validates :country, :associated => true
  validates :server_id, :presence => true
  validates :country_id, :presence => true
  
  validates :name, :presence => true, :uniqueness => { :case_sensitive => false, :scope => :server_id }
  validates :email, :format => { :with => /\A\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+\z/ }, :if => lambda { !email.blank? }


  def providers_with_authorization_to(permission_id)
    Authorization.where(permission_label_id: permission_id,
                        title_provider_group_id: title_provider_group_name.title_provider_groups(:select => :id)).collect {|auth| auth.title_provider_group.provider}
  end
  
  def list_dpi
    DPI.join(",")
  end

  private

  def self.order_by_name_select_country(pays)
    if pays == 0
      Title.order("name ASC")
    else
      Title.order("name ASC").where(:country_id => pays)
    end
  end

  def self.export_to_csv(titles, icono_title, icono_users, part_title, part_users)
    export = ""
    export.encode!('UTF-8')
    CSV(export, {:col_sep => ";"}) do |csv|
      csv << [I18n.t('statistics.title'), "Titre stat", I18n.t('group'), I18n.t('type'), I18n.t('first_name'), I18n.t('last_name'), I18n.t('email'), I18n.t('phone'), I18n.t('address'), I18n.t('admin.providers.zip_code'), I18n.t('admin.providers.city'), I18n.t('admin.providers.country'), I18n.t('admin.title.ojd_link'), I18n.t('statut')]
      titles.each do |p|
          contact_data = [p.visible_name, p.name, p.group, p.title_type, p.first_name, p.last_name, p.email, p.phone, p.address, p.zip_code, p.city, p.country.name, p.ojd_link]
          contact_data << I18n.t(TITLE_VISIBLE[p.visible]) unless p.visible == 2
          csv << contact_data
      end
      unless icono_title.nil?
       icono_users.each do |p|
        contact_data = [icono_title, "", "", p.first_name, p.last_name, p.email, p.phone, "","","","",""]
        csv << contact_data
       end
      end
      unless part_title.nil?
       part_users.each do |p|
        contact_data = [part_title, "", "", p.first_name, p.last_name, p.email, p.phone, "","","","",""]
        csv << contact_data
       end
      end
    end
    export
  end

end
