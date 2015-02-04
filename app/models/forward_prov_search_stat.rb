require 'builder'
require 'net/http'
require 'logger'

MF_ROOT = File.expand_path(File.join(File.dirname(__FILE__), '../'))
ERR_PROVSEARSTAT = Logger.new(File.join(MF_ROOT,'..', 'log', 'comm_job.err'))
ERR_PROVSEARSTAT.formatter = proc { |severity, datetime, progname, msg|
  "[#{datetime}] [#{severity}] #{msg}\n"
}
LOG_PROVSEARSTAT = Logger.new(File.join(MF_ROOT,'..', 'log', 'comm_job.log'))
LOG_PROVSEARSTAT.formatter = proc { |severity, datetime, progname, msg|
    "[#{datetime}] [#{severity}] #{msg}\n"
}

class ForwardProvSearchStat

  attr_accessor :s_s_id, :stringkey, :result, :server_url
  attr_reader :api_response, :xml

  def initialize( s_s_id, stringkey, result,
                 server_url = "http://#{Server.find_by_name("Pixadmin").host}:#{Server.find_by_name("Pixadmin").api_port}/prov_searchstats.xml" )
    @cs_name = Server.find_by_is_self(true).name
    @s_s_id = s_s_id
    @stringkey = stringkey
    @result = result
    @server_url = server_url
    LOG_PROVSEARSTAT.info "** ForwardProvSearchStat initialize : id - #{s_s_id} provider #{stringkey} result #{result}"
  end

  def perform

    newjob = CommunicationOutJob.create
    xml = Builder::XmlMarkup.new
    xml.instruct!
    xml.forward_prov_searchstat {
      xml.message_id(newjob.id)
      xml.cs_name(@cs_name)
      xml.s_s_id(@s_s_id)
      xml.stringkey(@stringkey)
      xml.result(@result)
    }

    ERR_PROVSEARSTAT.warn("** ForwardProvSearchStat perform : xml - #{xml}")

    newxml = xml.target!
    bnewxml = newxml.chomp("<to_s/>")
    newjob.params = bnewxml
    newjob.done = 0
    newjob.save
    send_request(bnewxml)

    newjob.result = results
    newjob.done = 100
    newjob.save
#TODO call it is done
   end

   def results
     LOG_PROVSEARSTAT.info "** ForwardProvSearchStat results: code - #{@api_response.code}"
     LOG_PROVSEARSTAT.info "** ForwardProvSearchStat results: message - #{@api_response.message}"
    @api_response.body
   end

  def send_request(rxml)
    url = URI.parse(server_url)
    request = Net::HTTP::Post.new(url.path)
    request.body = rxml
    ERR_PROVSEARSTAT.warn("** Request request - #{request.body}")
    request.content_type = "text/xml"
    retries = [5, 10, 30, 5.minutes, 1.hour, 2.hours, 6.hours, 12.hours, 1.day, 4.days]
    begin
      @api_response = Net::HTTP.start(url.host, url.port) {|http| http.request(request)}
    rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError,
         Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError => e
      if delay = retries.shift
        ERR_PROVSEARSTAT.error("#{$!} - will be retried in #{delay} seconds" )
        sleep delay
        retry
      else
        ERR_PROVSEARSTAT.error("#{$!} - FATAL ERROR")
      end
    rescue
      if delay = retries.shift
        ERR_PROVSEARSTAT.error("#{$!} - will be retried in #{delay} seconds" )
        sleep delay
        retry
      else
        ERR_PROVSEARSTAT.error("#{$!} - FATAL ERROR")
      end
    end
  end

  def message_id
    @newJob.id
  end

end
