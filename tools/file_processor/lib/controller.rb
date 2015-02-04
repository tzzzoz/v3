class Controller

  def halt(signal)
    LOG.info("#{signal} called, shutting down...")
    @jpeg_ftp_reader.conn.close
    @connection.stop
    exit
  end

  def process

    @connection = Bunny.new
    begin
      @connection.start
    rescue Bunny::ServerDownError => e
      LOG.fatal("check if rabbitmq is up : #{e}")
      raise
      exit
    end
    topic = @connection.exchange('medias', :type => :topic)

    LOG.info "Starting publishers"

    tries = 0

    LOG.info "Cleaning input dir"
    @jpeg_fs_reader.each do |f|
      LOG.debug("puplishing #{f} on #{@ftp_config[:feed]}.image.iptc.hotfolder")
      topic.publish(f, :key => "#{@ftp_config[:feed]}.image.iptc.hotfolder")
    end

    loop do
      begin
        @jpeg_ftp_reader.ftp_list if tries == 0 || @jpeg_ftp_reader.blank?
        @jpeg_ftp_reader.each do |f|
          LOG.info "pub #{f} on #{@ftp_config[:feed]}.image.iptc.hotfolder"
          topic.publish(f, :key => "#{@ftp_config[:feed]}.image.iptc.hotfolder")
        end
# rescue SystemExit, Interrupt
#   exit
      rescue Exception => e
        tries += 1
        LOG.fatal("#{e} retrying in #{@ftp_config[:config][:scan_each]} secs, try : #{tries}")
        if tries >= @ftp_config[:config][:tries_before_reset]
          tries = 0
          LOG.fatal("resetting : max tries reached #{@ftp_config[:config][:tries_before_reset]}")
        end
        @jpeg_ftp_reader.conn.close
        sleep @ftp_config[:config][:scan_each]
        @jpeg_ftp_reader.connect
        retry
      end

      sleep @ftp_config[:config][:scan_each]
      tries = 0
    end
  end

  def run(ftp_config)
    @ftp_config = YAML.load_file(ftp_config)
    @jpeg_ftp_reader = FtpReader.new(@ftp_config)
    @jpeg_ftp_reader.connect
    @jpeg_fs_reader = FsReader.new(@ftp_config[:config][:in])
    process
  end

end
