class SettingsController < ApplicationController

  layout :false
  
  def edit
#    bg = current_user.setting.display_params[:background_color][-2,2].to_i(16)
#    ft = current_user.setting.display_params[:font_color][-2,2].to_i(16)

    @setting = current_user.setting
#    @setting.display_params[:background_color] = bg
#    @setting.display_params[:font_color] = ft
#    @setting

  end
  
  def update
    params[:setting][:display_params]['background_color'] = "##{("%02x" % params[:setting][:display_params]['background_color'])*3}"
    params[:setting][:display_params]['font_color'] = "##{("%02x" % params[:setting][:display_params]['font_color'])*3}"
    params[:setting][:display_params]['previsualisation'] = params[:setting][:display_params_previsualisation]
    params[:setting][:display_params]['display_text'] = params[:setting][:display_params_display_text]

    if current_user.setting.update_attributes(permitted_params)
      session[:locale] = current_user.setting.language
#      clic_save(11, current_user.id, 0)
    else
      redirect_to :action => "edit"
    end

  end

  private
  
  def permitted_params
    params.require(:setting).permit(:language, :display_params_display_text, :display_params_previsualisation, :default_sort, :reload_pref,
    :time_zone, display_params: [:background_color, :font_color, :previsualisation, :display_text])
  end
end
