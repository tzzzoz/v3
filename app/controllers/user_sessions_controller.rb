class UserSessionsController < ApplicationController

  skip_before_filter :set_time_zone

  skip_before_filter :login_required, :except =>[:destroy]
  skip_before_filter :set_locale, :only =>[:create]
 

  # render new.rhtml
  def new

    #select template for the homepage
    case root_url
      when "http://192.168.200.49/","http://agences.pixpalace.com/"
        @template="pixadmin"
        @com_frame="pixadmin"
      when "http://192.168.200.34/","http://2.pixpalace.com/"
        @template="pixpalace2"
        @com_frame="pixpalace2"
      when "http://192.168.211.7/","http://www.pixtrakk.com/"
        @template="pixtrakk"
        @com_frame="pixtrakk"
      when "http://192.168.200.35/","http://www.pixpalace.com/"
        @template="pixpalace"
        @com_frame="web"
      else
        @template="pixpalace"
        @com_frame="cs"
    end

    @user_session = UserSession.new

  end

  def new_pp
    @@login_pp = true
    @css_url = "http://vozimage.com/Portals/_default/Skins/skin_vozimage/skin.css"
    @target = @login_failed ? '_self' : '_blank'
    puts"****** new_pp - @@login_pp=#{@@login_pp}"
    puts"****** new_pp - @target=#{@target}"
    puts"****** new_pp - @login_failed=#{@login_failed}"
    @user_session = UserSession.new
  end

  def create

    @user_session = UserSession.new(permitted_params)

    if @user_session.save
      if current_user.roles_mask == 64
        current_user_session.destroy
        flash[:notice] = "#{I18n.t'admin.user.deactivated_account'}"
        redirect_to(root_url)
      else
        if session[:locale].nil?
          session[:locale] = current_user.setting[:language]
        else
          current_user.setting.update_attribute(:language, session[:locale])
        end
        if current_user.light_boxes.empty?
          current_user.light_boxes.create(:name => I18n.t('light_box.name'), :title_id => current_user.title_id)
        end
        if mobile_browser?
          current_user.setting.update_attribute(:default_per_page,8)
          current_user.setting.update_attribute(:display_params_previsualisation,0)
          current_user.setting.update_attribute(:display_params_display_text,0)
          cookies[:pw_provider_panel_state] = false
          cookies[:pw_search_panel_state] = false
          cookies['ui-tabs-1'] = -1
          cookies['ui-tabs-2'] = -1
        else
          cookies[:pw_search_panel_state] = false unless cookies[:pw_search_panel_state].present?
          cookies['ui-tabs-1'] = -1 unless cookies['ui-tabs-1'].present?
          cookies['ui-tabs-2'] = -1 unless cookies['ui-tabs-2'].present?
        end
        provbd = []
        provhd = []
        provvg = []
        tpgn = Title.find(current_user.title_id).title_provider_group_name.id
        provs = []
        TitleProviderGroup.joins(:provider).where(:title_provider_group_name_id => tpgn).order('providers.name').collect{|tpg| provs << tpg.provider_id}
        provs.each do |p|
          provbd[p] = 0
          provhd[p] = 0
          provvg[p] = 0
          provbd[p] = 1 unless Authorization.where(:permission_label_id => 1, :title_provider_group_id => TitleProviderGroup.where(:provider_id => p, :title_provider_group_name_id => tpgn)).empty?
          provhd[p] = 1 unless Authorization.where(:permission_label_id => 2, :title_provider_group_id => TitleProviderGroup.where(:provider_id => p, :title_provider_group_name_id => tpgn)).empty?
          provvg[p] = 1 unless Authorization.where(:permission_label_id => 3, :title_provider_group_id => TitleProviderGroup.where(:provider_id => p, :title_provider_group_name_id => tpgn)).empty?
        end
        session[:provs] = provs
        session[:provbd] = provbd
        session[:provhd] = provhd
        session[:provvg] = provvg
        border_color = []
        provs.each do |p|
         border_color[p] = current_user.setting.border_color_provider[p.to_s] if current_user.setting.border_color_provider.include?(p.to_s)
        end
        session[:border_color] = border_color

        redirect_back_or_default(home_url)
        flash[:notice] = "#{I18n.t'flash.logged_in_successfully'}"
      end
    else
      note_failed_signin
      # @login       = params[:user_session][:login]
      # @remember_me = params[:user_session][:remember_me]

      #select template for the homepage
      case root_url
        when "http://192.168.200.49/","http://agences.pixpalace.com/"
          @template="pixadmin"
          @com_frame="pixadmin"
        when "http://192.168.200.34/","http://2.pixpalace.com/"
          @template="pixpalace2"
          @com_frame="pixpalace2"
        when "http://192.168.211.7/","http://www.pixtrakk.com/"
          @template="pixtrakk"
          @com_frame="pixtrakk"
        when "http://192.168.200.35/","http://www.pixpalace.com/"
          @template="pixpalace"
          @com_frame="web"
        else
          @template="pixpalace"
          @com_frame="cs"
      end
      render :action => 'new'
    end
  end

  def destroy
    current_user_session.destroy
    flash[:notice] = "#{I18n.t'flash.you_have_been_logged_out'}"
    redirect_to(root_url)
  end

  def error
    render  :file => "#{Rails.public_path}/500.html", :layout => false, :status => 500
  end

  def denied
    render  :file => "#{Rails.public_path}/422.html", :layout => false, :status => 422
  end


  # Track failed login attempts
  def note_failed_signin
    flash[:notice] = "#{I18n.t'flash.log_in_failed_for'} '#{params[:user_session][:login]}'"
    logger.warn "Failed login for '#{params[:user_session][:login]}' from #{request.remote_ip} at #{Time.now.utc}"
  end

  private

  def permitted_params
    params.require(:user_session).permit(:login, :password)
  end

end
