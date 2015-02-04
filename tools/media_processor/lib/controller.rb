class Controller

#  def halt(signal)
#    LOG.info("#{signal} called, shutting down...")
#    AMQP.stop{ EM.stop }
#    exit
#  end

  def process

      channel  = AMQP::Channel.new()
      exchange = channel.topic("medias")
      queue = channel.queue('media_processor').bind(exchange, :routing_key => '#')
      queue.subscribe(:ack => true) do |headers, file|
        tries = 0
        LOG.info "subs #{headers.routing_key} #{file}"
        begin
          media_processor = MediaWrapper::MediaProcessor.new(*headers.routing_key.split('.'))
          media_processor.process(file)
          headers.ack

        rescue ActiveRecord::StatementInvalid => e
          tries +=1
          LOG.fatal("DB problem : retrying #{tries} : #{e} : connected : #{ActiveRecord::Base.connected?}")
          ActiveRecord::Base.establish_connection
          sleep 3
          retry unless tries >= PROCESSOR_CONFIG[:controller][:db_retries]

        rescue SystemExit, Interrupt
          LOG.info("#{signal} called, shutting down...")
          AMQP.stop{ EM.stop }
          exit

        rescue Exception => e
          LOG.fatal("Unknown exception #{e} with #{file} : #{e.inspect} : skipping to next file : connected : #{ActiveRecord::Base.connected?}")
          headers.ack
          next

        end
      end
  end

  def run(fibers)
    LOG.info "Starting #{fibers} fibers"
    AMQP.start do
      fibers.times do
         process
      end
    end
  end

end