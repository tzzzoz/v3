require 'mq'
require File.dirname(__FILE__) + '/../../../../config/environment.rb'

LOG = DaemonKit::AbstractLogger.new("#{PW_LOG_ROOT}/message_from_MS_processor_#{DAEMON_ENV}.log")
PROCESSOR_CONFIG = DaemonKit::Config.load('processor').to_h
