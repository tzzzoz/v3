require 'net/ftp'
require 'fileutils'
require 'timeout'

class FtpReader

  attr_reader :conn

  def initialize(ftp_config)
    @ftp_config = ftp_config
  end

  def ftp_list
    LOG.debug('getting pictures listing')
    timeout(@ftp_config[:config][:timeout]){
      @ftp_list = @conn.nlst('-tr')
    }
    @ftp_list.delete_if{ |x| !is_jpg?(x) }
    LOG.debug("got #{@ftp_list.length} pictures listing")
  end

  def blank?
    @ftp_list.nil? || @ftp_list.empty?
  end

  def each
    tries = 0
    my_timout = @ftp_config[:config][:timeout]
    my_delai = @ftp_config[:config][:scan_each]
    @ftp_list.each do |f|
      begin
        LOG.debug("getting #{f}")
        status = Timeout::timeout(my_timout) { @conn.getbinaryfile(f, "#{@ftp_config[:config][:temp]}/#{f}") }

      rescue Timeout::Error => e
        tries += 1
        LOG.debug("'#{e} can't get file, retrying in #{my_delai} secs, try : #{tries}")
        sleep my_delai
        retry
      end
      FileUtils::mv("#{@ftp_config[:config][:temp]}/#{f}", "#{@ftp_config[:config][:in]}/")
      @ftp_list.delete(f)

      yield "#{@ftp_config[:config][:in]}/#{f}"

      begin
        status = Timeout::timeout(my_timout) { @conn.delete(f) }
      rescue Timeout::Error => e
        tries += 1
        LOG.debug("'#{e} can't delete file from list, retrying in #{my_delai} secs, try : #{tries}")
        sleep my_delai
        retry
      end
      LOG.debug("got #{f}")
    end
  end

  def connect
    tries = 0
    begin
      timeout(@ftp_config[:config][:timeout]) do
        unless @ftp_config[:proxy][:host]
          @conn = Net::FTP.new(@ftp_config[:connexion][:host], @ftp_config[:connexion][:user], @ftp_config[:connexion][:passwd])
          @conn.passive = true if @ftp_config[:connexion][:active] == false
        else
          @conn = Net::FTP.new
          @conn.connect(@ftp_config[:proxy][:host], @ftp_config[:proxy][:port])
          @conn.passive = true
          @conn.login("#{@ftp_config[:connexion][:user]}@#{@ftp_config[:connexion][:host]}", @ftp_config[:connexion][:passwd])
        end
        # net/ftp workaround, either the commands can stuck...
        @conn.binary = false
        #
        @conn.resume = true
        #@conn.debug_mode = true
      end

    rescue Exception => e
      tries += 1
      LOG.fatal("'#{e} can't connect, retrying in #{@ftp_config[:config][:scan_each]} secs, try : #{tries}")
      sleep @ftp_config[:config][:scan_each]
      retry
    end

  end

  def is_jpg?(f)
    ext = f.split('.')[-1].downcase
    false == ext.match(/jpg|jpeg|jpe/).nil?
  end

end
