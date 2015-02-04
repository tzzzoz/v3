#require 'spreadsheet'
require 'net/ftp'

class Admin::UsersController < ApplicationController
  attr_reader :users
  layout :false
  before_filter :login_required

  def index
    if params[:title_id]
      @users = User.order('login ASC').where(:title_id => params[:title_id]).all
    else
      @users = User.order('login ASC').all
    end
  end

  def new
    @user = User.new
    @user.title_id = params[:title_id] if params[:title_id]
    @emergency = 2
    @emergency = 0 if Server.find_by_is_self(true).name == "webAgencesV2FR2"
  end

  def edit
    @user = User.find(params[:id])
    @current_title = @user.title_id
    @emergency = 2

    if Server.find_by_is_self(true).name == "webAgencesV2FR2"
        @emergency = 0
        Spreadsheet.open USERS_LIST_FILE do |excel_users_file|
          login_tab = excel_users_file.worksheet 2
          login_tab.each do |row|
            if row[13].to_i == @user.id
              @emergency = 1
              break
            end
          end
        end
    end
  end

  def create
    @user = User.new(permitted_params)
    @user.setting = Setting.create(current_user.passed_settings)
    @user.setting.display_params['previsualisation'] = "1"
    @user.setting.display_params['background_color'] = "#909090"
    @user.setting.display_params['font_color'] = "#080808"
    @user.setting.display_params['display_text'] = "1"
    @user.setting.reload_pref = 1

    if @user.save
      if (@user.roles_mask != 1) && (Title.find(@user.title_id).name != 'pixways') && (Server.find_by_is_self(true).name == "webAgencesV2FR2")
        #create user in the Excel file
        create_user_excel(@user)
        #user copy on PixPalace Plus and backup
        ppplus_replication("pixpalaceplus",@user)
        ppplus_replication("pixpalaceplus_backup",@user)
      end
       redirect_to admin_users_path(:title_id => @user.title_id)
     else
       render :action => :new
     end
   end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(permitted_params)
      if (@user.roles_mask != 1) && (Title.find(@user.title_id).name != 'pixways') && (Server.find_by_is_self(true).name == "webAgencesV2FR2")
        #update user in the Excel file
        update_user_excel(@user)
        #user copy on PixPalace Plus and backup
        ppplus_replication("pixpalaceplus",@user)
        ppplus_replication("pixpalaceplus_backup",@user)
      end
      redirect_to admin_users_path(:title_id => @user.title_id)
    else
      render :action => :edit
    end
  end

  def destroy
    #@user = User.find(params[:id])
    #@user.destroy
  end

  def ppplus_replication(database_config_name,cur_user)
    cur_title= Title.find(cur_user.title_id)
    #only french users
    unless Country.find(cur_title.country_id).name!='France'
      begin
        config_db_ppplus = Rails.configuration.database_configuration[database_config_name]
        ppplus_client = Mysql2::Client.new(:host => config_db_ppplus["host"],:database => config_db_ppplus["database"],:username => config_db_ppplus["username"], :password => config_db_ppplus["password"])
      rescue Mysql2::Error => e
        logger.error Time.now().strftime("%Y-%m-%d %H:%M:%S ")+"[ERROR] #{e.message} on "+config_db_ppplus["host"]
        flash[:notice] =  'Echec de la replication sur PixPalace2'
        return
      end
      #Get id of country "France"
      begin
        ppplus_country_id=ppplus_client.query("select id from countries where name='France'").first['id']
      rescue Mysql2::Error => e
        logger.error Time.now().strftime("%Y-%m-%d %H:%M:%S ")+"[ERROR] #{e.message} on "+config_db_ppplus["host"]
      rescue
        ppplus_country_id=1
        logger.warn 'Warning : "France" country does not exist, title country will be 1'
      end
      #id of group "tout_titre"
      ppplus_group_id=2
      #Create title if it doesn't exist, otherwise update it
      begin
        ppplus_title_id=ppplus_client.query("select id from titles where name='#{cur_title.name.gsub(/'/,"\\\\'")}'").first['id']
        escaped_query="update titles set name=\"#{cur_title.name}\",hide_unauthorized_providers=#{cur_title.hide_unauthorized_providers},dpi=#{cur_title.dpi},flow_path=\"#{cur_title.flow_path}\",server_id=1,country_id=#{ppplus_country_id},updated_at=\"#{cur_title.updated_at}\",first_name=\"#{cur_title.first_name}\",last_name=\"#{cur_title.last_name}\",address=\"#{cur_title.address}\",zip_code=\"#{cur_title.zip_code}\",city=\"#{cur_title.city}\",phone=\"#{cur_title.phone}\",email=\"#{cur_title.email}\",comment=\"#{cur_title.comment}\",visible=#{cur_title.visible},titles.group=\"#{cur_title.group}\",title_type=\"#{cur_title.title_type}\",visible_name=\"#{cur_title.visible_name}\" where id =#{ppplus_title_id};".gsub(/'/,"\\\\'")
        ppplus_client.query(escaped_query)
      rescue Mysql2::Error => e
        logger.error Time.now().strftime("%Y-%m-%d %H:%M:%S ")+"[ERROR] #{e.message} on "+config_db_ppplus["host"]
      rescue
        escaped_query="insert into titles (name,hide_unauthorized_providers,dpi,flow_path,title_provider_group_name_id,server_id,country_id,created_at,updated_at,first_name,last_name,address,zip_code,city,phone,email,comment,visible,titles.group,title_type,visible_name) values (\"#{cur_title.name}\",#{cur_title.hide_unauthorized_providers},#{cur_title.dpi},\"#{cur_title.flow_path}\",#{ppplus_group_id},1,#{ppplus_country_id},\"#{cur_title.created_at}\",\"#{cur_title.updated_at}\",\"#{cur_title.first_name}\",\"#{cur_title.last_name}\",\"#{cur_title.address}\",\"#{cur_title.zip_code}\",\"#{cur_title.city}\",\"#{cur_title.phone}\",\"#{cur_title.email}\",\"#{cur_title.comment}\",#{cur_title.visible},\"#{cur_title.group}\",\"#{cur_title.title_type}\",\"#{cur_title.visible_name}\");".gsub(/'/,"\\\\'")
        ppplus_client.query(escaped_query)
        ppplus_title_id = ppplus_client.query("select id from titles where name='#{cur_title.name.gsub(/'/,"\\\\'")}'").first['id']
      end
      #Create user if it doesn't exist, otherwise update it
      begin
        ppplus_user_id=ppplus_client.query("select id from users where login='#{cur_user.login}'").first['id']
        escaped_query="update users set first_name=\"#{cur_user.first_name}\",last_name=\"#{cur_user.last_name}\",email=\"#{cur_user.email}\",phone=\"#{cur_user.phone}\",login=\"#{cur_user.login}\",crypted_password=\"#{cur_user.crypted_password}\",salt=\"#{cur_user.salt}\",persistence_token=\"#{cur_user.persistence_token}\",perishable_token=\"#{cur_user.perishable_token}\",updated_at=\"#{cur_user.updated_at}\",password_updated_at=\"#{cur_user.password_updated_at}\",roles_mask=\"#{cur_user.roles_mask}\",title_id=#{ppplus_title_id} where id=#{ppplus_user_id};".gsub(/'/,"\\\\'")
        ppplus_client.query(escaped_query)
      rescue Mysql2::Error => e
        logger.error Time.now().strftime("%Y-%m-%d %H:%M:%S ")+"[ERROR] #{e.message} on "+config_db_ppplus["host"]
      rescue
        escaped_query="insert into users (first_name,last_name,email,phone,login,crypted_password,salt,persistence_token,perishable_token,created_at,updated_at,password_updated_at,roles_mask,title_id) values (\"#{cur_user.first_name}\",\"#{cur_user.last_name}\",\"#{cur_user.email}\",\"#{cur_user.phone}\",\"#{cur_user.login}\",\"#{cur_user.crypted_password}\",\"#{cur_user.salt}\",\"#{cur_user.persistence_token}\",\"#{cur_user.perishable_token}\",\"#{cur_user.created_at}\",\"#{cur_user.updated_at}\",\"#{cur_user.password_updated_at}\",\"#{cur_user.roles_mask}\",#{ppplus_title_id});".gsub(/'/,"\\\\'")
        ppplus_client.query(escaped_query)
        ppplus_user_id=ppplus_client.query("select id from users where login='#{cur_user.login}'").first['id']
      end
      user_pwd=params[:user][:password]
      if user_pwd.blank?
        #Get user password from Excel file
        login_found=false
        user_pwd=""
        Spreadsheet.open USERS_LIST_FILE do |excel_users_file|
          excel_users_file.worksheets.each do |sheet|
            sheet.each do |row|
              if row[6].to_s == cur_user.login
                user_pwd = row[7].to_s
                login_found=true
                break
              end
            end
            if login_found
              break
            end
          end
        end
      end
      unless user_pwd.blank?
        #Update pixlogs table (for automatic login from PP to PP+)
        begin
          ppplus_client.query("select company from pixlogs where username='#{cur_user.login}'").first['company']
          ppplus_client.query("update pixlogs set company='#{user_pwd}' where username='#{cur_user.login}'")
        rescue Mysql2::Error => e
          logger.error Time.now().strftime("%Y-%m-%d %H:%M:%S ")+"[ERROR] #{e.message} on "+config_db_ppplus["host"]
        rescue
          ppplus_client.query("insert into pixlogs (username,company) values ('#{cur_user.login}','#{user_pwd}')")
        end
      end
      #Create settings if they doesn't exist
      begin
        ppplus_client.query("select id from settings where user_id=#{ppplus_user_id}").first['id']
      rescue Mysql2::Error => e
        logger.error Time.now().strftime("%Y-%m-%d %H:%M:%S ")+"[ERROR] #{e.message} on "+config_db_ppplus["host"]
      rescue
        cur_user.setting = Setting.create(current_user.passed_settings) if cur_user.setting.blank?
        ppplus_user_display_params="---\nbackground_color: ! '#{cur_user.setting.display_params['background_color']}'\nfont_color: ! '#{cur_user.setting.display_params['font_color']}'\nprevisualisation: '#{cur_user.setting.display_params['previsualisation']}'\ndisplay_text: '#{cur_user.setting.display_params['display_text']}'\n"
        ppplus_user_border_color_provider="--- {}\n"
        escaped_query="insert into settings (language,preferential_corpus,display_params,border_color_provider,user_id,created_at,updated_at,time_zone,default_per_page,default_since,default_sort) values (\"#{cur_user.setting.language}\",\"#{cur_user.setting.preferential_corpus}\",\"#{ppplus_user_display_params}\",\"#{ppplus_user_border_color_provider}\",#{ppplus_user_id},\"#{cur_user.setting.created_at}\",\"#{cur_user.setting.updated_at}\",\"#{cur_user.setting.time_zone}\",#{cur_user.setting.default_per_page},\"#{cur_user.setting.default_since}\",\"#{cur_user.setting.default_sort}\");".gsub(/'/,"\\\\'")
        ppplus_client.query(escaped_query)
      end
      ppplus_client.close
    end
  end

  def create_user_excel(cur_user)
    title_name = Title.find(cur_user.title_id).name

    server_name = Server.find(Title.find(cur_user.title_id).server_id).name

    tmpfilename = USERS_LIST_FILE[0..USERS_LIST_FILE.length-5]+"_tmp_"+Time.now.strftime("%H-%M-%S")+".xls"
    FileUtils::cp(USERS_LIST_FILE,tmpfilename)

    #Spreadsheet.client_encoding='UTF-8'
    Spreadsheet.open tmpfilename do |excel_users_file|

      if params[:user][:add_role_to_user]=='deactivated'
        tab_to_update = excel_users_file.worksheet 3
      else
        if params[:emergency_account]
          tab_to_update = excel_users_file.worksheet 2
        else
          if server_name=='webAgencesV2FR2'
            tab_to_update = excel_users_file.worksheet 1
          else
            tab_to_update = excel_users_file.worksheet 0
          end
        end
      end
      tab_urls = excel_users_file.worksheet 4
      tab_titles = excel_users_file.worksheet 5

      #search for title's group in the Excel file
      group_name=""
      #1-search in the titles tab
      tab_titles.each do |row|
        if row[0]==cur_user.title_id
          group_name = row[2]
        end
      end
      #2-if not found search in the other tabs
      if group_name.blank?
        for sheet_num in 0..3
          sheet = excel_users_file.worksheet sheet_num
          sheet.each do |row|
            if row[14].to_s == cur_user.title_id.to_s
              group_name = row[2]
              break
            end
          end
          break unless group_name.blank?
        end
      end
      #3-if still not found in the Excel file the use the group from database
      group_name ||= TitleProviderGroupName.find(Title.find(cur_user.title_id).title_provider_group_name_id).name

      nb_rows = tab_to_update.last_row_index+1
      tab_to_update[nb_rows,0] = server_name
      tab_to_update[nb_rows,1] = title_name
      tab_to_update[nb_rows,2] = group_name
      tab_to_update[nb_rows,3] = cur_user.first_name
      tab_to_update[nb_rows,4] = cur_user.last_name
      tab_urls.each do |row|
        if row[0]==server_name
          tab_to_update[nb_rows,5]=row[1]
          tab_to_update[nb_rows,12]=row[2]
          break
        end

      end

      tab_to_update[nb_rows,6] = cur_user.login
      tab_to_update[nb_rows,7] = params[:user][:password]
      tab_to_update[nb_rows,8] = I18n.t(params[:user][:add_role_to_user],:locale => :fr)
      tab_to_update[nb_rows,9] = cur_user.email
      unless cur_user.created_at.nil?
        tab_to_update[nb_rows,10] = cur_user.created_at.strftime("%d/%m/%Y %H:%M")

      end

      tab_to_update[nb_rows,13] = cur_user.id
      tab_to_update[nb_rows,14] = cur_user.title_id

      tab_to_update.column_count.times do |c|
        tab_to_update.row(nb_rows).set_format(c,tab_to_update.row(nb_rows-1).format(c))
      end

      #all worksheets have to be updated to be written in the new file
      excel_users_file.worksheets.each do |sheet|
        sheet[0,0] = sheet[0,0]
      end

      excel_users_file.write USERS_LIST_FILE

    end

    FileUtils::rm(tmpfilename,:force=>true)

    ftp = Net::FTP.new("192.168.0.51")
    #ftp.passive = true
    ftp.login("listuser", "wx98qs65")
    ftp.putbinaryfile(USERS_LIST_FILE,(File.basename(USERS_LIST_FILE)[0..File.basename(USERS_LIST_FILE).length-5]+"_"+Time.now.strftime("%d-%m-%Y")+".xls"))
    ftp.close

  end



  def update_user_excel(cur_user)

    title_name = Title.find(cur_user.title_id).name
    server_name = Server.find(Title.find(cur_user.title_id).server_id).name
    login_found = false
    sheet_found = -1
    row_found = -1
    pwd_save = ""
    comment_save = ""

    tmpfilename = USERS_LIST_FILE[0..USERS_LIST_FILE.length-5]+"_tmp_"+Time.now.strftime("%H-%M-%S")+".xls"
    FileUtils::cp(USERS_LIST_FILE,tmpfilename)

    #Spreadsheet.client_encoding='UTF-8'
    Spreadsheet.open tmpfilename do |excel_users_file|

      #searching for the user
      excel_users_file.worksheets.each_with_index do |sheet,sheet_index|
        sheet.each_with_index do |row,row_index|
          if row[13].to_s== params[:id].to_s
            login_found = true
            pwd_save = row[7].to_s
            comment_save = row[11].to_s
            sheet_found = sheet_index
            row_found = row_index
            break
          end
        end
        if login_found
          break
        end
      end

      #rewrite the whole sheet and erase the row of the user
      if login_found
        sheet = excel_users_file.worksheet sheet_found
        sheet.each_with_index do |row,row_index|
          row_save = row
          if row_index==sheet.last_row_index
            sheet.insert_row(row_index)
          else
            if row_index>=row_found
              sheet.insert_row(row_index,sheet.row(row_index+1))
            else
              sheet.insert_row(row_index,row_save)
            end
            sheet.column_count.times do |c|
              sheet.row(row_index).set_format(c,row_save.format(c))
            end
          end
        end
      end

      #writing of the user
      if params[:user][:add_role_to_user]=='deactivated'
        tab_to_update_index = 3
      else
        if params[:emergency_account]
          tab_to_update_index = 2
        else
          if server_name=='webAgencesV2FR2'
            tab_to_update_index = 1
          else
            tab_to_update_index = 0
          end
        end
      end

      tab_to_update = excel_users_file.worksheet tab_to_update_index
      tab_urls = excel_users_file.worksheet 4

      tab_titles = excel_users_file.worksheet 5

      #search for title's group in the Excel file
      #1-search in the titles tab
      group_name=""
      tab_titles.each do |row|
        if row[0]==cur_user.title_id
          group_name = row[2]
        end
      end
      #2-if not found search in the other tabs
      if group_name.blank?
        for sheet_num in 0..3
          sheet = excel_users_file.worksheet sheet_num
          sheet.each do |row|
            if row[14].to_s == cur_user.title_id.to_s
              group_name = row[2]
              break
            end
          end
          break unless group_name.blank?
        end
      end
      #3-if still not found in the Excel file the use the group from database
      group_name ||= TitleProviderGroupName.find(Title.find(cur_user.title_id).title_provider_group_name_id).name

      if tab_to_update_index==sheet_found
        #nb_rows = tab_to_update.last_row_index
        nb_rows = tab_to_update.row_count-1
      else
        #nb_rows = tab_to_update.last_row_index+1
        nb_rows = tab_to_update.row_count
      end

      tab_to_update[nb_rows,0] = server_name
      tab_to_update[nb_rows,1] = title_name
      tab_to_update[nb_rows,2] = group_name
      tab_to_update[nb_rows,3] = cur_user.first_name
      tab_to_update[nb_rows,4] = cur_user.last_name
      tab_urls.each do |row|
        if row[0]==server_name
          tab_to_update[nb_rows,5]=row[1]
          tab_to_update[nb_rows,12]=row[2]
          break
        end
      end

      tab_to_update[nb_rows,6] = cur_user.login
      if params[:user][:password].blank?
        tab_to_update[nb_rows,7] = pwd_save
      else
        tab_to_update[nb_rows,7] = params[:user][:password]
      end
      tab_to_update[nb_rows,8] = I18n.t(params[:user][:add_role_to_user],:locale => :fr)
      tab_to_update[nb_rows,9] = cur_user.email

      unless cur_user.created_at.nil?
        tab_to_update[nb_rows,10] = cur_user.created_at.strftime("%d/%m/%Y %H:%M")
      end

      tab_to_update[nb_rows,11] = comment_save
      if (sheet_found!=2 and params[:user][:add_role_to_user]=='deactivated')
        tab_to_update[nb_rows,11]= tab_to_update[nb_rows,11].to_s+' '+I18n.t('deactivated',:locale => :fr)+' le '+ Time.now.strftime("%d/%m/%Y %H:%M")
      elsif (sheet_found==2 and params[:user][:add_role_to_user]!='deactivated')
        tab_to_update[nb_rows,11]= tab_to_update[nb_rows,11].to_s+' '+I18n.t('admin.user.reactivated',:locale => :fr)+' le '+ Time.now.strftime("%d/%m/%Y %H:%M")
      end

      tab_to_update[nb_rows,13] = params[:id]
      tab_to_update[nb_rows,14] = cur_user.title_id

      tab_to_update.column_count.times do |c|
        tab_to_update.row(nb_rows).set_format(c,tab_to_update.row(1).format(c))
      end

      #all worksheets have to be updated to avoid missing datas
      excel_users_file.worksheets.each do |sheet|
        sheet[0,0] = sheet[0,0]
      end

      excel_users_file.write USERS_LIST_FILE

    end

    FileUtils::rm(tmpfilename,:force=>true)

    ftp = Net::FTP.new("192.168.0.51")
    #ftp.passive = true
    ftp.login("listuser", "wx98qs65")
    ftp.putbinaryfile(USERS_LIST_FILE,(File.basename(USERS_LIST_FILE)[0..File.basename(USERS_LIST_FILE).length-5]+"_"+Time.now.strftime("%d-%m-%Y")+".xls"))
    ftp.close
  end

  def permitted_params
    params.require(:user).permit(:title_id, :add_role_to_user, :login, :first_name, :last_name, :email, :phone, :password, :password_confirmation)
  end
end