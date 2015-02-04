require 'builder'
require 'net/http'
require 'logger'

MI_ROOT = File.expand_path(File.join(File.dirname(__FILE__), '../'))
LOG_IMGERR = Logger.new(File.join(MI_ROOT,'..', 'log', 'comm_job.err'))
LOG_IMGERR.formatter = proc { |severity, datetime, progname, msg|
  "[#{datetime}] [#{severity}] #{msg}\n"
}
LOG_IMGLOG = Logger.new(File.join(MI_ROOT,'..', 'log', 'comm_job.log'))
LOG_IMGLOG.formatter = proc { |severity, datetime, progname, msg|
    "[#{datetime}] [#{severity}] #{msg}\n"
}

class ForwardImgDemand

  attr_accessor :im_id, :user_login, :operation, :api_key, :server_url
  attr_reader :api_response, :xml

  def initialize( im_id,
                 user_login, operation,
                 api_key = "#{Server.find_by_name("Pixadmin").api_key}",
                 server_url = "http://#{Server.find_by_name("Pixadmin").host}:#{Server.find_by_name("Pixadmin").api_port}/img_demand.xml" )
    @cs_name = Server.find_by_is_self(true).name
    @im_id = im_id
    @user_login = user_login
    @ope = operation
    @api_key = api_key
    @server_url = server_url
    LOG_IMGLOG.info "** ForwardImgDemand initialize : im_id = #{im_id} user = #{user_login} url = #{server_url}"
  end

  def perform

    newjob = CommunicationOutJob.create
    xml = Builder::XmlMarkup.new
    xml.instruct!
    xml.forward_img_demand {
      xml.message_id(newjob.id)
      xml.api_key(@api_key)
      xml.cs_name(@cs_name)
      xml.im_id(@im_id)
      xml.user_login(@user_login)
      xml.operation(@ope)
    }

    LOG_IMGERR.warn("** ForwardImgDemand perform : xml = #{xml}")

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
     LOG_IMGLOG.info "** ForwardImgDemand results: code - #{@api_response.code}"
     LOG_IMGLOG.info "** ForwardImgDemand results: message - #{@api_response.message}"
    @api_response.body
   end

  def send_request(rxml)
    url = URI.parse(server_url)
    request = Net::HTTP::Post.new(url.path)
    request.body = rxml
    LOG_IMGERR.warn("** Img Demand body - #{request.body}  url = #{url}")
    request.content_type = "text/xml"
    retries = [5, 10, 30, 5.minutes, 1.hour, 1.day]
    begin
      @api_response = Net::HTTP.start(url.host, url.port) {|http| http.request(request)}
    rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError,
         Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError => e
      if delay = retries.shift
        LOG_IMGERR.error("#{$!} - will be retried in #{delay} seconds" )
        sleep delay
        retry
      else
        LOG_IMGERR.error("#{$!} - FATAL ERROR")
      end
    rescue
      if delay = retries.shift
        LOG_IMGERR.error("#{$!} - will be retried in #{delay} seconds" )
        sleep delay
        retry
      else
        LOG_IMGERR.error("#{$!} - FATAL ERROR")
      end
    end
  end


  def message_id
    @newJob.id
  end

end
