class BorderColorProvidersController < ApplicationController

  layout :false

  def update
    bcp = {}
    u = current_user
    @border_color_provider = u.setting.border_color_provider
    params['providers'].keys.each{|p| bcp[p] = params['color-result']}
    @border_color_provider.merge!(bcp)
    u.setting.update_attributes(:border_color_provider => @border_color_provider) unless bcp.blank?
    border_color = []
    session[:provs].each do |p|
     border_color[p] = u.setting.border_color_provider[p.to_s] if u.setting.border_color_provider.include?(p.to_s)
    end
    session[:border_color] = border_color
#    clic_save(1,u.id,1)
  end

  def destroy
    u = current_user
    @border_color_provider = u.setting.border_color_provider
    if params['providers']
      @border_color_provider.delete_if {|k| params['providers'].keys.include?(k) }
      u.setting.update_attributes(:border_color_provider => @border_color_provider) unless params['providers'].blank?
    end
    border_color = []
    session[:provs].each do |p|
     border_color[p] = u.setting.border_color_provider[p.to_s] if u.setting.border_color_provider.include?(p.to_s)
    end
    session[:border_color] = border_color
#    clic_save(1,u.id,2)
  end

  def index
    @border_color_provider = current_user.setting.border_color_provider
#    clic_save(1,current_user.id,0)
  end

end
