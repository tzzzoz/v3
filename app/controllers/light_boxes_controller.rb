# encoding: utf-8
#require 'capistrano'
require 'fileutils'
require 'net/ftp'
require "mysql2"

class LightBoxesController < ApplicationController

  before_filter :current_user_light_boxes
  after_filter :store_current_light_box, :except => :update

  def show
    @light_box = @light_boxes.find(params[:id])
    init_html
    redirect_to :action => :index if @light_box.nil?
  end

  def index
    #TODO PL modal dialog for opening full screen light-box (sync light-box in main)
    @light_box = @light_boxes.find_by_id(session[:active_light_box]) || @light_boxes.last
    init_html
    @ids = params[:ids]
    render :action => :show, :layout => false
  end


  def edit
    @light_box = @light_boxes.find_by_id(params[:id])
  end

  def destroy
     @light_boxes.find(params[:id]).destroy
     @light_box = @light_boxes.last
     init_html
#     clic_save(3,current_user.id,2)
     render :action => :show
  end

  def create
    @light_box = @light_boxes.create(permitted_params.merge(:title => current_user.title))
    init_html
#    clic_save(3,current_user.id,0)
    render :action => :show
  end

  def update
    @light_box = @light_boxes.find(params[:id])
    @light_box.update_attributes(permitted_params)
    init_html
#    clic_save(3,current_user.id,1)
    render :action => :show, :layout => false
  end

  def send_and_delete
    @light_box = @light_boxes.find(params[:id])
    lb = @light_box.name

    imgs = []
    imgs = @light_box.images.collect{|im| im.file_name if (im.has_right(current_user,'HD') && (im.content_error === false)) }
    imgs.compact!
    imgs.sort
    if imgs.count < 1
      render :action => :show, flash[:notice_lightbox] => "Vous n'avez pas les droits d'effacement."
    else
      util = current_user
      if params[:pplus]
        inDir = "pixpalaceplus"
        ims = []
        ims = @light_box.images.collect{|im| im if (im.has_right(current_user,'HD') && (im.content_error === false)) }
        ims.compact!
        ims.sort
        ims.each do |i|
          file = "public#{i.medium_location}"
          ftp = Net::FTP.new("192.168.200.3")
          ftp.passive = true
          ftp.login("pixadmin_temp", "aip6de6i")
          ftp.chdir(inDir)
          ftp.putbinaryfile(file, i.file_name)
          ftp.close
        end

        inDir = "pixpalaceplus2"
        ims.each do |i|
          file = "public#{i.medium_location}"
          ftp = Net::FTP.new("192.168.200.3")
          ftp.passive = true
          ftp.login("pixadmin_temp", "aip6de6i")
          ftp.chdir(inDir)
          ftp.putbinaryfile(file, i.file_name)
          ftp.close
        end
        UserMailer.warn_pplus_user(imgs, util, lb).deliver
      else
        UserMailer.warn_user(imgs, util, lb).deliver
      end
      deleting_images(imgs,util.title.name.gsub(/[^a-zA-Z0_9]/,""))
      init_html
      render :action => :show, flash[:notice_lightbox] => "Demande transmise, l'effacement est en cours de traitement."
    end
  end
  
  private

  def current_user_light_boxes
    @light_boxes ||= current_user.light_boxes
  end
  
  def store_current_light_box
    session[:active_light_box] = @light_box.id
  end

  def init_html
    @lb_images = @light_box.images.where(:content_error => 0).order('position DESC')
  end

  def deleting_images(imgs,titlename)

    local_tmp_path = '/home/v2/support/tmp/'
    remote_tmp_path ='/tmp/'
    capistrano_path = '/home/v2/capistrano/pixpalace-v2html/'
    txt_file_name = Time.now.strftime("%Y-%m-%d-%Hh%Mm%S")+"_#{titlename}.txt"
    ini_file_name = Time.now.strftime("%Y-%m-%d-%Hh%Mm%S")+"_#{titlename}.ini"
    at_ini_file_name = Time.now.strftime("%Y-%m-%d-%Hh%Mm%S")+"_#{titlename}.at-ini"
    remote_log_file = '/var/log/pixways/delete_images/'+Time.now.strftime("%Y-%m-%d-%Hh%Mm%S")+"_#{titlename}.log"
    ultra_delete_log_file = '/var/log/pixways/delete_images/'+Time.now.strftime("%Y-%m-%d-%Hh%Mm%S")+"_#{titlename}.ultra-log"
    ultra_invoke_log_file = '/var/log/pixways/delete_images/'+Time.now.strftime("%Y-%m-%d-%Hh%Mm%S")+"_#{titlename}.delete-log"
    sleep_delay = 120+(imgs.length/15) #delay to let the delete processing before retrieving each server log

    #writing ini file
    File.open(local_tmp_path+ini_file_name,'wb') do |f|
      f.write("/var/www/v2/current/tools/delete_images_egal #{remote_tmp_path}#{txt_file_name} 1>>#{remote_log_file} 2>&1")
    end

    #writing txt file
    File.open(local_tmp_path+txt_file_name,'wb') do |f|
      imgs.each do |i|
        f.write(i+"\n")
      end
    end

    #writing ini file for the at command
    File.open(local_tmp_path+at_ini_file_name,'wb') do |f|
      f.write("echo '*** Processing ultra_delete ***' >>#{ultra_delete_log_file}\n")
      f.write("echo >>#{ultra_delete_log_file}\n")
      f.write("#{capistrano_path}ultra_delete.sh #{ini_file_name} #{txt_file_name} 1>>#{ultra_delete_log_file} 2>&1\n")
      f.write("sleep #{sleep_delay}\n")
      f.write("echo '*** SERVERS LOGS ***' >>#{ultra_invoke_log_file}\n")
      f.write("echo >>#{ultra_invoke_log_file}\n")
      f.write(capistrano_path+'ultra_invoke.sh "ps -ef |grep delete_images |grep -v grep; tail -1 '+remote_log_file+';wc -l '+remote_log_file+'" 1>> '+ultra_invoke_log_file+' 2>&1'+"\n")
      f.write("echo >>#{ultra_invoke_log_file}\n")
      f.write("echo '---------------------' >>#{ultra_invoke_log_file}\n")
      f.write("echo '*** PICTURES LIST (#{imgs.length}) ***' >>#{ultra_invoke_log_file}\n")
      f.write("echo >>#{ultra_invoke_log_file}\n")
      f.write("cat #{remote_tmp_path}#{txt_file_name} >>#{ultra_invoke_log_file}\n")
      f.write("sendemail -f effacements@pixpalace.com -t effacements@pixpalace.com -s 192.168.222.252 -u 'Log effacement #{titlename} #{Time.now.strftime("%Y-%m-%d-%Hh%Mm%S")}' -o message-file=#{ultra_invoke_log_file} -a #{ultra_delete_log_file} -l /var/log/pixways/delete_images_sendemail.log -v")
    end

    #calling ultra_delete
    pid = Process.spawn("at -f #{local_tmp_path}#{at_ini_file_name} now")
    Process.detach(pid)

  end

  def permitted_params
    params.require(:light_box).permit(:name)
  end
  
end
