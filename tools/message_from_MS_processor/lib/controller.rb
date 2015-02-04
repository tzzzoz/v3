class Controller

  def halt(signal)
    LOG.info("#{signal} called")
  end

  def process
      tries = 0
      begin
        client = Mysql2::Client.new(:host => "192.168.203.1", :username => "mspixfr", :password => "isa1956")
        client.query("use main_server")
        result = client.query("SELECT mtpa_id, mtpa_created_at, mtpa_message, mtpa_param1, mtpa_param2, mtpa_param3, mtpa_param4, mtpa_param5 FROM MessageToPA WHERE mtpa_done = 0")
        LOG.info "result: #{result}"
        results.each do |row|
          case row[mtpa_message]
          when "FILE_HAS_NO_IPTC"
              #do like# processResult = ProcessMSmessage(row[mtpa_message], row[mtpa_param1], row[mtpa_param2], row[mtpa_param3], row[mtpa_param4], row[mtpa_param5])
              # processResult 1 - OK, more then 1 - error code
          end
          result = client.query("UPDATE MessageToPA SET mtpa_done = #{processResult}")
        end
        
      rescue ActiveRecord::StatementInvalid => e
        tries +=1
        LOG.fatal("DB problem : retrying #{tries} : #{e}")
        sleep 3
        retry unless tries >= PROCESSOR_CONFIG[:controller][:db_retries]

      rescue SystemExit
        raise

      rescue Exception => e
        LOG.fatal("Unknown exception #{e} with #{file} : #{e.inspect}")
        next
      end
  end

  def run(workers)
    LOG.info "Starting #{workers} subscribers"
  end

end
