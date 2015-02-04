require 'builder'
require 'net/http'
require 'logger'

MG_ROOT = File.expand_path(File.join(File.dirname(__FILE__), '../'))
ERR_FIELDSTAT = Logger.new(File.join(MG_ROOT,'..', 'log', 'comm_job.err'))
ERR_FIELDSTAT.formatter = proc { |severity, datetime, progname, msg|
  "[#{datetime}] [#{severity}] #{msg}\n"
}

class ForwardImageField

  attr_accessor :s_s_id, :field_name, :field_content, :server_url
  attr_reader :api_response, :xml

  def initialize( s_s_id, field_name, field_content,
                 server_url = "http://#{Server.find_by_name("Pixadmin").host}:#{Server.find_by_name("Pixadmin").api_port}/image_field.xml" )
    @cs_name = Server.find_by_is_self(true).name
    @s_s_id = s_s_id
    @field_name = field_name
    @field_content = field_content
    @server_url = server_url
    ERR_FIELDSTAT.info "** ForwardImageField initialize : id - #{s_s_id} name #{field_name} content #{field_content}"
  end

  def perform

    newjob = CommunicationOutJob.create
    xml = Builder::XmlMarkup.new
    xml.instruct!
    xml.forward_image_field {
      xml.message_id(newjob.id)
      xml.cs_name(@cs_name)
      xml.s_s_id(@s_s_id)
      xml.field_name(@field_name)
      xml.field_content(@field_content)
    }

    ERR_FIELDSTAT.warn("** ForwardImageField perform : xml - #{xml}")

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
     ERR_FIELDSTAT.info "** ForwardImageField results: code - #{@api_response.code}"
     ERR_FIELDSTAT.info "** ForwardImageField results: message - #{@api_response.message}"
    @api_response.body
   end

  def send_request(rxml)
    url = URI.parse(server_url)
    request = Net::HTTP::Post.new(url.path)
    request.body = rxml
    ERR_FIELDSTAT.warn("** Request  - #{request.body}")
    request.content_type = "text/xml"
    retries = [5, 10, 30, 5.minutes, 1.hour, 2.hours, 6.hours, 12.hours, 1.day, 4.days]
    begin
      @api_response = Net::HTTP.start(url.host, url.port) {|http| http.request(request)}
    rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError,
         Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError => e
      if delay = retries.shift
        ERR_FIELDSTAT.error("#{$!} - will be retried in #{delay} seconds" )
        sleep delay
        retry
      else
        ERR_FIELDSTAT.error("#{$!} - FATAL ERROR")
      end
    rescue
      if delay = retries.shift
        ERR_FIELDSTAT.error("#{$!} - will be retried in #{delay} seconds" )
        sleep delay
        retry
      else
        ERR_FIELDSTAT.error("#{$!} - FATAL ERROR")
      end
    end
  end

  def message_id
    @newJob.id
  end

end
