require 'builder'
require 'net/http'
require 'logger'

MB_ROOT = File.expand_path(File.join(File.dirname(__FILE__), '../'))
LOG_BNFERR = Logger.new(File.join(MB_ROOT,'..', 'log', 'comm_job.err'))
LOG_BNFERR.formatter = proc { |severity, datetime, progname, msg|
  "[#{datetime}] [#{severity}] #{msg}\n"
}
LOG_BNFLOG = Logger.new(File.join(MB_ROOT,'..', 'log', 'comm_job.log'))
LOG_BNFLOG.formatter = proc { |severity, datetime, progname, msg|
    "[#{datetime}] [#{severity}] #{msg}\n"
}

class ForwardBnfFormJob

  attr_accessor :parameters, :user_login, :title_name, :api_key, :server_url
  attr_reader :api_response, :xml

  def initialize( parameters,
                 user_login, title_name, 
                 api_key = "#{Server.find_by_name("Pixadmin").api_key}",
                 server_url = "http://#{Server.find_by_name("Pixadmin").host}:#{Server.find_by_name("Pixadmin").api_port}/bnf_form.xml" )
    @cs_name = Server.find_by_is_self(true).name
    @parameters = parameters
    @user_login = user_login
    @title_name = title_name
    @api_key = api_key
    @server_url = server_url
    LOG_BNFLOG.info "** ForwardBnfFormJob initialize : parameters = #{parameters} user = #{user_login} title = #{title_name}"
  end

  def perform

    newjob = CommunicationOutJob.create
#    build_request
    xml = Builder::XmlMarkup.new
    xml.instruct!
    xml.forward_bnf_form {
      xml.message_id(newjob.id)
      xml.api_key(@api_key)
      xml.cs_name(@cs_name)
      xml.parameters(@parameters)
      xml.user_login(@user_login)
      xml.title_name(@title_name)
    }

    LOG_BNFERR.warn("** ForwardBnfFormJob perform : xml - #{xml}")

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
     LOG_BNFLOG.info "** ForwardBnfFormJob results: code - #{@api_response.code}"
     LOG_BNFLOG.info "** ForwardBnfFormJob results: message - #{@api_response.message}"
    @api_response.body
   end
   
  def send_request(rxml)
    url = URI.parse(server_url)
    request = Net::HTTP::Post.new(url.path)
    request.body = rxml
    LOG_BNFERR.warn("** request - #{request.body}")
    request.content_type = "text/xml"
    retries = [5, 10, 30, 5.minutes, 1.hour, 2.hours, 6.hours, 12.hours, 1.day, 4.days]
    begin
      @api_response = Net::HTTP.start(url.host, url.port) {|http| http.request(request)}
    rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError,
         Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError => e
      if delay = retries.shift
        LOG_BNFERR.error("#{$!} - will be retried in #{delay} seconds" )
        sleep delay
        retry
      else
        LOG_BNFERR.error("#{$!} - FATAL ERROR")
      end
    rescue
      if delay = retries.shift
        LOG_BNFERR.error("#{$!} - will be retried in #{delay} seconds" )
        sleep delay
        retry
      else
        LOG_BNFERR.error("#{$!} - FATAL ERROR")
      end
    end
  end  

  
  def message_id
    @newJob.id
  end
  
end
