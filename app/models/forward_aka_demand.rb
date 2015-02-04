require 'builder'
require 'net/http'
require 'logger'

MJ_ROOT = File.expand_path(File.join(File.dirname(__FILE__), '../'))
LOG_AKA = Logger.new(File.join(MJ_ROOT,'..', 'log', 'comm_job.err'))
LOG_AKA.formatter = proc { |severity, datetime, progname, msg|
  "[#{datetime}] [#{severity}] #{msg}\n"
}

class ForwardAkaDemand

  attr_accessor :vid_id, :user_login, :operation, :api_key, :server_url
  attr_reader :api_response, :xml

  def initialize( vid_id,
                 user_login,
                 api_key = "#{Server.find_by_name("Pixadmin").api_key}",
                 server_url = "http://#{Server.find_by_name("Pixadmin").host}:#{Server.find_by_name("Pixadmin").api_port}/aka_demand.xml" )
    @cs_name = Server.find_by_is_self(true).name
    @vid_id = vid_id
    @user_login = user_login
    @api_key = api_key
    @server_url = server_url
    LOG_AKA.info "** ForwardAkaDemand initialize : video = #{vid_id} user = #{user_login} url = #{server_url}"
  end

  def perform

    newjob = CommunicationOutJob.create
    xml = Builder::XmlMarkup.new
    xml.instruct!
    xml.forward_aka_demand {
      xml.message_id(newjob.id)
      xml.api_key(@api_key)
      xml.cs_name(@cs_name)
      xml.vid_id(@vid_id)
      xml.user_login(@user_login)
    }

    LOG_AKA.warn("** ForwardAkaDemand perform : xml = #{xml}")

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
     LOG_AKA.info "** ForwardAkaDemand results: code - #{@api_response.code}"
     LOG_AKA.info "** ForwardAkaDemand results: message - #{@api_response.message}"
    @api_response.body
   end

  def send_request(rxml)
    url = URI.parse(server_url)
    request = Net::HTTP::Post.new(url.path)
    request.body = rxml
    LOG_AKA.warn("** Aka Demand body - #{request.body}  url = #{url}")
    request.content_type = "text/xml"
    retries = [5, 10, 30, 5.minutes, 1.hour, 1.day]
    begin
      @api_response = Net::HTTP.start(url.host, url.port) {|http| http.request(request)}
    rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError,
         Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError => e
      if delay = retries.shift
        LOG_AKA.error("#{$!} - will be retried in #{delay} seconds" )
        sleep delay
        retry
      else
        LOG_AKA.error("#{$!} - FATAL ERROR")
      end
    rescue
      if delay = retries.shift
        LOG_AKA.error("#{$!} - will be retried in #{delay} seconds" )
        sleep delay
        retry
      else
        LOG_AKA.error("#{$!} - FATAL ERROR")
      end
    end
  end


  def message_id
    @newJob.id
  end

end
