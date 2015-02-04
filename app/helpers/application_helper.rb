module ApplicationHelper

  def bg_color
      current_user && current_user.setting.display_params['background_color'] || "#ccc"
  end

  def fg_color
      current_user && current_user.setting.display_params['font_color'] || "#000"
  end

  def abs_image_tag(source, options = {})
	  @host_with_port ||= request.protocol << request.host_with_port
	  source = "/#{source}" unless source =~ %r{^/}
	  image_tag("#{@host_with_port}#{source}", options)
  end

  def dynamic_css
    @pw_bgcolor = current_user.setting.display_params['background_color']
    @pw_ftcolor = current_user.setting.display_params['font_color']

    style = "<style type='text/css'>
    #pw_search_form, .dropdown-menu, .popover-content, #search_tabs, #navigation2, .panel-header, .pw_panel-header, .pw_panel-content, .pw_menu_2, ul.pw_submenu li, #tabs-thumbs .ui-widget-content, .pw_info_thumb, .pw_content, .content, #pw_search_panel, #pw_light_box_panel, #pw_search_form .ui-state-hover, #pw_search_form .ui-state-focus, #light_box_form_place .ui-state-focus, #light_box_form_place .ui-state-hover, .pw_select_manager_add.ui-state-focus, .pw_panel-header-label.ui-state-focus, .pw_panel-header .pw_panel-header-label, #select_pictures_form, .result_content{
        background-color: #{@pw_bgcolor};
    }
    #pw_search_form, #pw_header .ui-widget-header, #pw_right .ui-widget-header, #pw_center .ui-widget-header, #pw_center .ui-widget-content, #pw_light_box_panel, .pw_content, .content, .pw_panel-header, #pw_search_form .ui-state-hover, #pw_search_form .ui-state-focus, #light_box_form_place .ui-state-focus, #light_box_form_place .ui-state-hover, #pw_panel_carrousel.ui-state-default, .pw_select_manager_add.ui-state-focus, .pw_panel-header-label.ui-state-focus{
        border-color: #{@pw_bgcolor};
    }
    #pw_statistics_list tbody, #pw_search_form, #pw_media_all, #navigation2 a, .pw_panel-header, .pw_panel-content, .pw_content, .content, .pw_content a, .content a,
    .pw_menus li a:link, .pw_menus li a:visited,
    .pw_menu_2 li, .pw_menu_2 li a:visited, .pw_menu_2 li a:link,
    .pw_submenu li a,
    .pw_menus_3 li a:link, .pw_menus_3 li a:visited,
    .pw_thumb p, .pw_stats_thumb p,
    .pw_stats_export a:link, .pw_stats_export a:visited,
    .pw_info_thumb, .pw_panel-header .ui-state-active, .pw_total_photos, .gap, .pw_toggle_check, .pw_stats_total,
    .pw_panel-header-content a.pw_tpgn_link, .pw_title_panel,
    #select_pictures_form, .carousel-caption{
        color: #{@pw_ftcolor};
    }

    </style>"
  end

  def same_bg_css
    style = "<style type='text/css'>
    body, .pw_close_window{
        background-color: #{@pw_bgcolor};
    }
    .ui-state-hover{
        border-color: #{@pw_bgcolor};
    }
    </style>"
  end

  def get_dossier
    dossiers = {}
    csv_text = File.read('print_outdos.csv')
    csv = CSV.parse(csv_text, :col_sep => ";", :headers => false)
    csv.each do |row|
      dossiers[row[0]] = row[1]
    end
    dossiers
  end

  def textilize(text)
    Textilizer.new(text).to_html.html_safe unless text.blank?
  end

  def default_setting_per_page
    current_user.setting.default_per_page
  end

  def default_setting_since
    current_user.setting.default_since
  end

  def default_setting_sort
    current_user.setting.default_sort
  end

  def pw_link_to_button_in_tabs(name, link)
    raw "<input type='button' class='link_button_in_tabs' data-href='#{link}' value='#{name}' /> #{link_to name, link, :class => 'link_button'}"
  end

  def img_date(cdat)
     return cdat.strftime('%d/%m/%Y')
  end

end

