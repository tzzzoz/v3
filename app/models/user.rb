require 'digest/sha1'

class User < ActiveRecord::Base
  acts_as_authentic do |c|
    c.transition_from_restful_authentication = true
    c.merge_validates_length_of_password_field_options(:minimum => 6)
    c.logged_in_timeout = 5.hours
    c.crypto_provider = Authlogic::CryptoProviders::Sha512
  end

  easy_roles :roles_mask, :method => :bitmask

  ROLES_MASK = %w[superadmin editor_admin editor_user provider_admin provider_user photographer deactivated]

  disable_perishable_token_maintenance(true)
  before_create :reset_perishable_token
  after_create :create_first_light_box

  belongs_to  :title
  belongs_to  :country
  has_many    :light_boxes, :dependent => :destroy
  has_many    :search_provider_group_names
  has_many    :request_to_providers
  has_many    :statistics
  has_one     :setting
  has_many    :saved_searches
  has_many    :photo20mins, :dependent => :destroy

  validates_presence_of     :login
  validates_length_of       :login,    :within => 3..40
  #validates_uniqueness_of   :login
  validates_format_of       :login,    :with => Authlogic::Regex.login #, :message => Authlogic.bad_login_message
  validates_presence_of     :email
  validates_length_of       :email,    :within => 6..100 #r@a.wk
  validates_uniqueness_of   :email
  validates_format_of       :email,    :with => Authlogic::Regex.email #, :message => Authlogic.bad_email_message



  # before_create :check_ability

  before_save :set_password_updated_at

  #before_destroy :continue_delete?

  # HACK HACK HACK -- how to do attr_accessible from here?
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  #attr_accessible :login, :email, :password, :password_confirmation, :title_id, :first_name, :last_name, :role_id, :phone, :jobcity,
  #  :activity_sector, :company, :non_tva, :billing_company, :service, :country, :zip_code, :fax, :tva, :billing_address, :job, :permissions
  # :country is usefull ony for web users, maybe use a STI
  attr_accessor :send_activation_mail

  serialize :permissions


  #virtual attribute: full_name
  def full_name
    "#{first_name} #{last_name}"
  end

  def login=(value)
    write_attribute :login, (value ? value.downcase : nil)
  end

  def email=(value)
    write_attribute :email, (value ? value.downcase : nil)
  end

  def self.current
    UserSession.find.user
  end


  def add_role_to_user
   :add_role_to_user
  end

  def add_role_to_user=(value)
   clear_roles
   add_role(value)
  end

  #creates new user and activate it (for admin mode)
  #TODO: Sami if user_setting.errors.empty?
#  def self.create_new_user(my_params)
#    user = User.new(my_params[:user_params])
#
#    if user.save && user.errors.empty?
#      my_params[:setting][:user_id] = user.id
#
#      setting = Setting.create(my_params[:setting])
#      @current_errors = setting.errors unless setting.errors.empty?
#      user.send_activation_mail = false
#    else
#      @current_errors = user.errors
#    end
#    @current_errors
#  end

  #when an admin creates a user, his settings are passed to the created user (borders, language, time zone ...)
  def passed_settings
    customized_setting = setting.attributes
    ['id', 'user_id', 'updated_at', 'created_at'].each do |attr|
      customized_setting.delete(attr)
    end
    customized_setting
  end

#  def create_settings_for_new_web_user
#    Setting.create(  :user_id => id,
#    :language => "fr",
#    :preferential_corpus => { :internal   => true,
#      :stock      => true,
#      :external   => false,
#      :editorial  => false,
#      :pix_palace => true},
#      :display_params => {  :background_color          => "#DFDFE1",
#        :display_tag_cloud         => true,
#        :previsualisation          => true, "display_credit_under_vignette" => true,
#        :vignette_size             => "2",
#        :font_color                => "#5B5D60",
#        :slider_font_value         => "-86",
#        :slider_background_value   => "-211",
#        :full_screen_display_image => "other_page"})
#      end

#      def deliver_password_reset_instructions!
#        reset_perishable_token!
#        UserMailer.deliver_password_reset_instructions(self)
#      end

      ##### Admin #####

      def providers_group
        title.title_provider_group_name
      end

      def providers
        is_superadmin? ? Provider.order('name ASC') : providers_group.providers.order('name ASC')
      end

      # TODO: is it usefull ?? better use a scope if yes
      def visible_users
        is_superadmin? ? User.all : title.users
      end

      # TODO: is it usefull ?? better use a scope if yes
      def find_visible_users_by_title_id(title_id)
        is_superadmin? ? User.where(title_id: title_id) : title.users
      end


      def set_password_updated_at
        self.password_updated_at = Time.now unless password_confirmation.blank?
      end

#      def active?
#        !title_id.nil?
#      end
#
#      def password_required?
#        !password.blank?
#      end

      private

      def create_first_light_box
        if self.light_boxes.count == 0
          self.light_boxes << LightBox.new(:name => I18n.t('light_box.name'), :title_id => self.title_id)
        end
      end

  end
