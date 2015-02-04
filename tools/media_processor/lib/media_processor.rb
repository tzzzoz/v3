require 'amqp'
require 'yaml'
require 'logger'
require 'fileutils'
require 'fiber'

MP_ROOT = File.expand_path(File.join(File.dirname(__FILE__), '../'))
LOG = Logger.new(File.join(MP_ROOT,'..','..', 'log', 'media_processor.log'))
LOG.formatter = proc { |severity, datetime, progname, msg|
  "[#{datetime}] [#{severity}] #{msg}\n"
}

require File.join(MP_ROOT, 'lib', 'pp_exception.rb')
require File.join(MP_ROOT, 'lib', 'controller.rb')
require File.join(MP_ROOT, 'lib', 'media_wrapper.rb')
require File.join(MP_ROOT, 'lib', 'feeds', 'feed.rb')
require File.join(MP_ROOT, 'lib', 'feeds', 'pixpalace.rb')
require File.join(MP_ROOT, 'lib', 'feeds', 'pixtrakk.rb')
require File.join(MP_ROOT, 'lib', 'feeds', 'local.rb')

# load rails
require File.join(MP_ROOT,'..','..', 'config', 'environment.rb')
#ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + "/debug.log")

PROCESSOR_CONFIG = YAML.load_file(File.join(MP_ROOT, 'config', 'processor.yml'))

module MediaWrapper

  class MediaProcessor

    attr_accessor :provider, :path, :meta, :media, :type, :folder, :feed

    def initialize(feed, media_type, type, folder)
      raise PpException::CantWriteToFs unless File.writable?(PROCESSOR_CONFIG[:paths][:out])
      @feed = feed.to_sym
      @media_type = media_type.to_sym
      @type = type.to_sym
      @folder = folder.to_sym
    end

    def process(path)
      begin
        @path = path
        @provider = provider_from_file_name(path)
        @media = MediaWrapper.class_eval(@media_type.to_s.capitalize).new(path)
        mapping = MetadataConversion.send("#{@type}_to_#{@media_type}")
        @meta = @media.send("read_#{@type}", mapping)
        current_feed = MediaWrapper.class_eval(@feed.to_s.capitalize).new(self)
        current_feed.process
        current_feed.write

      rescue PpException::UnknownProvider
        LOG.error("PpException::UnknownProvider #{File.basename(@path)}")
        if @folder == :hotfolder
          err_folder = "#{PROCESSOR_CONFIG[:paths][:err]}/Unknown/#{File.ctime(@path).utc.strftime("%Y%m%d")}/"
          FileUtils::makedirs(err_folder)
          FileUtils.mv(@path, err_folder)
        end

      rescue PpException::NoReceptionDate
        LOG.error("PpException::NoReceptionDate #{File.basename(@path)}")
        if @folder == :hotfolder
          err_folder = "#{PROCESSOR_CONFIG[:paths][:err]}/NoReceptionDate/#{File.ctime(@path).utc.strftime("%Y%m%d")}/"
          FileUtils::makedirs(err_folder)
          FileUtils.mv(@path, err_folder)
        end

      rescue PpException::BadMaxAvailSize
        LOG.error("PpException::BadMaxAvailSize #{File.basename(@path)}")
        if @folder == :hotfolder
          err_folder = "#{PROCESSOR_CONFIG[:paths][:err]}/BadMaxAvailSize/#{File.ctime(@path).utc.strftime("%Y%m%d")}/"
          FileUtils::makedirs(err_folder)
          FileUtils.mv(@path, err_folder)
        end

      rescue PpException::OlderServerTimeForUpdate
        LOG.error("PpException::OlderServerTimeForUpdate #{File.basename(@path)}")
        if @folder == :hotfolder
          err_folder = "#{PROCESSOR_CONFIG[:paths][:err]}/Older/#{File.ctime(@path).utc.strftime("%Y%m%d")}/"
          FileUtils::makedirs(err_folder)
          FileUtils.mv(@path, err_folder)
        end

      rescue PpException::SaifEmptyPhotographe
        LOG.error("PpException::SaifEmptyPhotographe #{File.basename(@path)}")
        if @folder == :hotfolder
          err_folder = "#{PROCESSOR_CONFIG[:paths][:err]}/Saif/#{File.ctime(@path).utc.strftime("%Y%m%d")}/"
          FileUtils::makedirs(err_folder)
          FileUtils.mv(@path, err_folder)
        end
      
      rescue PpException::NotUpdatableFeed
        LOG.error("PpException::NotUpdatableFeed #{File.basename(@path)}")
        if @folder == :hotfolder
          err_folder = "#{PROCESSOR_CONFIG[:paths][:err]}/NotUpdatableFeed/#{File.ctime(@path).utc.strftime("%Y%m%d")}/"
          FileUtils::makedirs(err_folder)
          FileUtils.mv(@path, err_folder)
        end

      rescue PpException::MsImageIdProblem
        LOG.error("PpException::MsImageIdProblem #{File.basename(@path)}")
        if @folder == :hotfolder
          err_folder = "#{PROCESSOR_CONFIG[:paths][:err]}/MsImageIdProblem/#{File.ctime(@path).utc.strftime("%Y%m%d")}/"
          FileUtils::makedirs(err_folder)
          FileUtils.mv(@path, err_folder)
        end

      end
    end

    private

    def provider_from_file_name(path)
      if @feed == :pixpalace
        provider = ::Provider.get_from_file_name(path)
      elsif @feed == :local
        provider = ::Provider.get_from_input_dir( File.dirname(File.expand_path(path)) )
#      elsif @feed == :pixtrakk
#        provider = ::Provider.get_from_file_name(path)
      end
      raise PpException::UnknownProvider if provider.nil?
      provider
    end

  end
end
