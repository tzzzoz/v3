require 'builder'
require 'net/http'
require 'logger'

MD_ROOT = File.expand_path(File.join(File.dirname(__FILE__), '../'))
LOG_REQ_ERR = Logger.new(File.join(MD_ROOT,'..', 'log', 'comm_job.err'))
LOG_REQ_ERR.formatter = proc { |severity, datetime, progname, msg|
  "[#{datetime}] [#{severity}] #{msg}\n"
}
LOG_REQ_LOG = Logger.new(File.join(MD_ROOT,'..', 'log', 'comm_job.log'))
LOG_REQ_LOG.formatter = proc { |severity, datetime, progname, msg|
    "[#{datetime}] [#{severity}] #{msg}\n"
}

class ForwardRequestJob

  attr_accessor :request_text, :user_login, :serial, :provider, :api_key, :server_url
  attr_reader :api_response, :xml

  def initialize( request_text, user_login, serial, provider,
                 api_key = "#{Server.find_by_name("Pixadmin").api_key}",
                 server_url = "http://#{Server.find_by_name("Pixadmin").host}:#{Server.find_by_name("Pixadmin").api_port}/requests.xml" )
    @cs_name = Server.find_by_is_self(true).name
    @request_text = request_text
    @user_login = user_login
    @serial = serial
    @provider = provider
    @api_key = api_key
    @server_url = server_url
    LOG_REQ_LOG.info "** ForwardrequestJob initialize : text - #{request_text} login #{user_login} serial #{serial} provider #{provider}"
  end

  def perform

    newjob = CommunicationOutJob.create
#    build_request
    xml = Builder::XmlMarkup.new
    xml.instruct!
    xml.forward_request {
      xml.message_id(newjob.id)
      xml.api_key(@api_key)
      xml.cs_name(@cs_name)
      xml.request_text(@request_text)
      xml.user_login(@user_login)
      xml.serial(@serial)
      xml.provider(@provider)
    }

    LOG_REQ_ERR.warn("** ForwardrequestJob perform : xml - #{xml}")

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
     LOG_REQ_LOG.info "** ForwardRequestJob results: code - #{@api_response.code}"
     LOG_REQ_LOG.info "** ForwardRequestJob results: message - #{@api_response.message}"
    @api_response.body
   end
   
  def send_request(rxml)
    url = URI.parse(server_url)
    request = Net::HTTP::Post.new(url.path)
    request.body = rxml
    LOG_REQ_ERR.warn("** Request request - #{request.body}")
    request.content_type = "text/xml"
    retries = [5, 10, 30, 5.minutes, 1.hour, 2.hours, 6.hours, 12.hours, 1.day, 4.days]
    begin
      @api_response = Net::HTTP.start(url.host, url.port) {|http| http.request(request)}
    rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError,
         Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError => e
      if delay = retries.shift
        LOG_REQ_ERR.error("#{$!} - will be retried in #{delay} seconds" )
        sleep delay
        retry
      else
        LOG_REQ_ERR.error("#{$!} - FATAL ERROR")
      end
    rescue
      if delay = retries.shift
        LOG_REQ_ERR.error("#{$!} - will be retried in #{delay} seconds" )
        sleep delay
        retry
      else
        LOG_REQ_ERR.error("#{$!} - FATAL ERROR")
      end
    end
  end  

  
  def build_request
    @xml = Builder::XmlMarkup.new
    @xml.instruct!
    @xml.forward_lr_stat {
      @xml.message_id(@newJob.id)
      @xml.api_key(@api_key)
      @xml.cs_name(@cs_name)
      @xml.image_name(@image_name)
      @xml.agency_name(@agency_name)
      @xml.operation_label_id(@operation_label_id)
      @xml.user_login(@user_login)
      @xml.title_name(@title_name)
    }

  end
  
  def message_id
    @newJob.id
  end
  
end
