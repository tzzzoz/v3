require 'builder'
require 'net/http'
require 'logger'

ME_ROOT = File.expand_path(File.join(File.dirname(__FILE__), '../'))
ERR_SEARSTAT = Logger.new(File.join(ME_ROOT,'..', 'log', 'comm_job.err'))
ERR_SEARSTAT.formatter = proc { |severity, datetime, progname, msg|
  "[#{datetime}] [#{severity}] #{msg}\n"
}
LOG_SEARSTAT = Logger.new(File.join(ME_ROOT,'..', 'log', 'comm_job.log'))
LOG_SEARSTAT.formatter = proc { |severity, datetime, progname, msg|
    "[#{datetime}] [#{severity}] #{msg}\n"
}

class ForwardSearchStat

  attr_accessor :s_s_id, :skeyword, :ssince, :tri, :pp_from, :pp_to, :photo_from, :photo_to, :formt, :result, :user_login, :cs_created, :server_url
  attr_reader :api_response, :xml

  def initialize( s_s_id, skeyword, ssince, tri, pp_from, pp_to, photo_from, photo_to, formt, result, user_login, cs_created,
                 server_url = "http://#{Server.find_by_name("Pixadmin").host}:#{Server.find_by_name("Pixadmin").api_port}/searchstats.xml" )
    @cs_name = Server.find_by_is_self(true).name
    @s_s_id = s_s_id
    @skeyword = skeyword
    @ssince = ssince
    @tri = tri
    @pp_from = pp_from
    @pp_to = pp_to
    @photo_from = photo_from
    @photo_to = photo_to
    @formt = formt
    @result = result
    @user_login = user_login
    @cs_created = cs_created
    @server_url = server_url
    LOG_SEARSTAT.info "** ForwardSearchStat initialize : id - #{s_s_id} login #{user_login} keyword #{skeyword}"
  end

  def perform

    newjob = CommunicationOutJob.create
    xml = Builder::XmlMarkup.new
    xml.instruct!
    xml.forward_searchstat {
      xml.message_id(newjob.id)
      xml.cs_name(@cs_name)
      xml.s_s_id(@s_s_id)
      xml.skeyword(@skeyword)
      xml.ssince(@ssince)
      xml.tri(@tri)
      xml.pp_from(@pp_from)
      xml.pp_to(@pp_to)
      xml.photo_from(@photo_from)
      xml.photo_to(@photo_to)
      xml.formt(@formt)
      xml.result(@result)
      xml.user_login(@user_login)
      xml.cs_created(@cs_created)
    }

    ERR_SEARSTAT.warn("** ForwardSearchStat perform : xml - #{xml}")

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
     LOG_SEARSTAT.info "** ForwardSearchStat results: code - #{@api_response.code}"
     LOG_SEARSTAT.info "** ForwardSearchStat results: message - #{@api_response.message}"
    @api_response.body
   end

  def send_request(rxml)
    url = URI.parse(server_url)
    request = Net::HTTP::Post.new(url.path)
    request.body = rxml
    ERR_SEARSTAT.warn("** Request - #{request.body}")
    request.content_type = "text/xml"
    retries = [5, 10, 30, 5.minutes, 1.hour, 2.hours, 6.hours, 12.hours, 1.day, 4.days]
    begin
      @api_response = Net::HTTP.start(url.host, url.port) {|http| http.request(request)}
    rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError,
         Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError => e
      if delay = retries.shift
        ERR_SEARSTAT.error("#{$!} - will be retried in #{delay} seconds" )
        sleep delay
        retry
      else
        ERR_SEARSTAT.error("#{$!} - FATAL ERROR")
      end
    rescue
      if delay = retries.shift
        ERR_SEARSTAT.error("#{$!} - will be retried in #{delay} seconds" )
        sleep delay
        retry
      else
        ERR_SEARSTAT.error("#{$!} - FATAL ERROR")
      end
    end
  end

  def message_id
    @newJob.id
  end

end
