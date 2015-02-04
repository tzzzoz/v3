class Admin::TitlesController < ApplicationController

  layout :false

  before_filter :login_required

  def index
    if params[:tpgn_id]
      @title_provider_group_name = TitleProviderGroupName.find(params[:tpgn_id])
      @titles = Title.order("name ASC").where(:title_provider_group_name_id => params[:tpgn_id]).all
    else
      @titles = Title.order("name ASC").all
    end
  end

  def new
    @title = Title.new
  end

  def show
    @title = Title.find(params[:id])
    @groupforfile=get_groupinfile(@title.id)
  end

  def create
    @title = Title.new(permitted_params)
    if @title.save
      if (@title.name != 'pixways') && (Server.find_by_is_self(true).name == "webAgencesV2FR2")
        create_title_excel(@title)
      end

      redirect_to([:admin, @title], :notice => I18n.t('successfully_created'))
    else
      render :action => :new
    end
  end

  def edit
    @title = Title.find(params[:id])
    @groupforfile=get_groupinfile(@title.id)
  end

  def update
    @title = Title.find(params[:id])
    if @title.update_attributes(permitted_params)
      if (@title.name != 'pixways') && (Server.find_by_is_self(true).name == "webAgencesV2FR2")
        update_title_excel(@title)
      end

      redirect_to([:admin, @title], :notice => I18n.t('successfully_updated'))
    else
      render :action => :edit
    end
  end

  def destroy
    #@title = Title.find(params[:id])
    #@title.destroy
  end

  private

  def get_groupinfile(title_id)
    groupinfile=""
    if Server.find_by_is_self(true).name == "webAgencesV2FR2"
      Spreadsheet.open USERS_LIST_FILE do |excel_users_file|
        #search in users tabs
        for sheet_num in 0..3
          sheet = excel_users_file.worksheet sheet_num
          sheet.each do |row|
            if row[14].to_i == title_id
              groupinfile = row[2]
              break
            end
          end
        end

        #search in titles tab
        excel_users_file.worksheet(5).each do |row|
          if row[0].to_i == title_id
            groupinfile = row[2]
            break
          end
        end
      end
    end
    groupinfile
  end

  def update_title_excel(cur_title)

    server_name = Server.find(cur_title.server_id).name

    #Spreadsheet.client_encoding='UTF-8'
    Spreadsheet.open USERS_LIST_FILE do |excel_users_file|

      tab_urls = excel_users_file.worksheet 4
      #update users tabs
      for sheet_num in 0..3
        sheet = excel_users_file.worksheet sheet_num
        sheet.each do |row|
          if row[14].to_s== params[:id].to_s
            row[0] = server_name
            row[1] = cur_title.name
            row[2] = params[:group_name]
            tab_urls.each do |row_urls|
              if row_urls[0]==server_name
                row[5]=row_urls[1]
                row[12]=row_urls[2]
                break
              end
            end
          end
        end
      end

      #update titles tab
      excel_users_file.worksheet(5).each do |row|
        if row[0].to_s== params[:id].to_s
          row[1] = cur_title.name
          row[2] = params[:group_name]
        end
      end

      #all worksheets have to be updated to avoid missing datas
      excel_users_file.worksheets.each do |sheet|
        sheet[0,0] = sheet[0,0]
      end

      File.delete(USERS_LIST_FILE)
      excel_users_file.write USERS_LIST_FILE
    end

    ftp = Net::FTP.new("192.168.0.51")
    #ftp.passive = true
    ftp.login("listuser", "wx98qs65")
    ftp.putbinaryfile(USERS_LIST_FILE,(File.basename(USERS_LIST_FILE)[0..File.basename(USERS_LIST_FILE).length-5]+"_"+Time.now.strftime("%d-%m-%Y")+".xls"))
    ftp.close

  end

  def create_title_excel(cur_title)

    server_name = Server.find(cur_title.server_id).name

    #Spreadsheet.client_encoding='UTF-8'
    Spreadsheet.open USERS_LIST_FILE do |excel_users_file|

      titles_tab = excel_users_file.worksheet 5
      row_index = titles_tab.last_row_index+1
      titles_tab[row_index,0] = cur_title.id
      titles_tab[row_index,1] = cur_title.name
      titles_tab[row_index,2] = params[:group_name]


      #all worksheets have to be updated to avoid missing datas
      excel_users_file.worksheets.each do |sheet|
        sheet[0,0] = sheet[0,0]
      end

      File.delete(USERS_LIST_FILE)
      excel_users_file.write USERS_LIST_FILE
    end

    ftp = Net::FTP.new("192.168.0.51")
    #ftp.passive = true
    ftp.login("listuser", "wx98qs65")
    ftp.putbinaryfile(USERS_LIST_FILE,(File.basename(USERS_LIST_FILE)[0..File.basename(USERS_LIST_FILE).length-5]+"_"+Time.now.strftime("%d-%m-%Y")+".xls"))
    ftp.close

  end

  private
  
  def permitted_params
    params.require(:title).permit(:name, :visible_name, :country_id, :title_provider_group_name_id, :server_id,
      :hide_unauthorized_providers, :dpi, :flow_path, :last_name, :first_name, :address, :zip_code, :city,
      :phone, :email, :visible, :group, :title_type, :comment, :ojd_link)
  end

end
