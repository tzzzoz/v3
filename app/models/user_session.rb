class UserSession < Authlogic::Session::Base
  after_create :init_attributes

  logout_on_timeout true

  private

  def init_attributes
    user.setting = Setting.create(:display_params => {}, :border_color_provider => {}) if user.setting.nil?
    user.setting.update_attribute(:display_params, {'previsualisation' => 1, 'display_text' => 0}) if user.setting.display_params.nil?
    user.setting.update_attribute(:border_color_provider, {}) if user.setting.border_color_provider.nil?
  end

end
