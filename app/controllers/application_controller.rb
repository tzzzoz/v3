require 'authentication_methods'

class ApplicationController < ActionController::Base

  rescue_from CanCan::AccessDenied do |exception|
    exception.default_message = I18n.t('flash.alert_cancan')
    flash[:alert] = exception.message
    redirect_to '/home'
  end


  helper :all
  include AuthenticationMethods

  helper_method :current_user_session, :current_user

  before_filter :login_required
  before_filter :set_locale
  before_filter :set_time_zone
  before_filter :prepend_view_path_if_mobile

  # TODO : Sami stop storing this in sessions and make it resful
  def set_locale
    session[:locale] = params[:locale] if params[:locale]
    I18n.locale = session[:locale] if session[:locale]
  end

  # TODO: remove session[:time_zone]
  def set_time_zone
    if current_user
      Time.zone = current_user.setting.time_zone unless current_user.setting.time_zone.blank?
    end
  end

  private

  def load_cached_search_params
    if params[:saved_search_id]
      @current_params = SavedSearch.find(params[:saved_search_id]).criteria
    elsif (params[:search] && cached_params = Rails.cache.read(params[:search]))
      @current_params = cached_params
    else
      @current_params = params
      @current_params[:providers] ||= {}
      @current_params[:users] ||= {}
      @current_params[:titles] ||= {}
    end
  end

  def prepend_view_path_if_mobile
    if mobile_browser?
      prepend_view_path Rails.root + 'app' + 'views' + 'mobile_views'
    end
  end

  def clic_save(page, util, acti)
#    Analytic.safe_save(:page_id => page.to_i, :user_id => util.to_i, :action_id => acti.to_i) unless User.find(util).title_id == 1
  end

  def mobile_browser?
    request.env["HTTP_USER_AGENT"] && request.env["HTTP_USER_AGENT"][/(iPhone|iPod|iPad|Android)/]
  end
  helper_method :mobile_browser?
  
end
