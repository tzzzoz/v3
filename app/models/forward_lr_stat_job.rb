require 'builder'
require 'net/http'
require 'logger'

MA_ROOT = File.expand_path(File.join(File.dirname(__FILE__), '../'))
LOG_ERR = Logger.new(File.join(MA_ROOT,'..', 'log', 'comm_job.err'))
LOG_ERR.formatter = proc { |severity, datetime, progname, msg|
  "[#{datetime}] [#{severity}] #{msg}\n"
}
LOG_LOG = Logger.new(File.join(MA_ROOT,'..', 'log', 'comm_job.log'))
LOG_LOG.formatter = proc { |severity, datetime, progname, msg|
    "[#{datetime}] [#{severity}] #{msg}\n"
}

class ForwardLrStatJob

  attr_accessor :image_name, :agency_name, :operation_label_id, :user_login, :title_name, :api_key, :server_url
  attr_reader :api_response, :xml

  def initialize( image_name, agency_name, operation_label_id,
                 user_login, title_name, 
                 api_key = "#{Server.find_by_name("Pixadmin").api_key}",
                 server_url = "http://#{Server.find_by_name("Pixadmin").host}:#{Server.find_by_name("Pixadmin").api_port}/lr_stats.xml" )
    @cs_name = Server.find_by_is_self(true).name
    @image_name = image_name
    @agency_name = agency_name
    @operation_label_id = operation_label_id
    @user_login = user_login
    @title_name = title_name
    @api_key = api_key
    @server_url = server_url
    LOG_LOG.info "** ForwardLrStatJob initialize : image - #{image_name}"
  end

  def perform

    newjob = CommunicationOutJob.create
#    build_request
    xml = Builder::XmlMarkup.new
    xml.instruct!
    xml.forward_lr_stat {
      xml.message_id(newjob.id)
      xml.api_key(@api_key)
      xml.cs_name(@cs_name)
      xml.image_name(@image_name)
      xml.agency_name(@agency_name)
      xml.operation_label_id(@operation_label_id)
      xml.user_login(@user_login)
      xml.title_name(@title_name)
    }

    LOG_ERR.warn("** ForwardLrStatJob perform : xml - #{xml}")

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
     LOG_LOG.info "** ForwardLrStatJob results: code - #{@api_response.code}"
     LOG_LOG.info "** ForwardLrStatJob results: message - #{@api_response.message}"
    @api_response.body
   end
   
  def send_request(rxml)
    url = URI.parse(server_url)
    request = Net::HTTP::Post.new(url.path)
    request.body = rxml
    LOG_ERR.warn("** url - #{url}")
    LOG_ERR.warn("** request - #{request}")
    LOG_ERR.warn("** request - #{request.body}")
    request.content_type = "text/xml"
    retries = [5, 10, 30, 5.minutes, 1.hour, 2.hours, 6.hours, 12.hours, 1.day, 4.days]
    begin
      @api_response = Net::HTTP.start(url.host, url.port) {|http| http.request(request)}
    rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError,
         Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError => e
      if delay = retries.shift
        LOG_ERR.error("#{$!} - will be retried in #{delay} seconds" )
        sleep delay
        retry
      else
        LOG_ERR.error("#{$!} - FATAL ERROR")
      end
    rescue
      if delay = retries.shift
        LOG_ERR.error("#{$!} - will be retried in #{delay} seconds" )
        sleep delay
        retry
      else
        LOG_ERR.error("#{$!} - FATAL ERROR")
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
