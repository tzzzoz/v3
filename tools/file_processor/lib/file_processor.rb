require 'bunny'
require 'yaml'
require 'logger'

FP_ROOT = File.expand_path(File.join(File.dirname(__FILE__), '../'))

require File.join(FP_ROOT, 'lib', 'ftp_reader.rb')
require File.join(FP_ROOT, 'lib', 'fs_reader.rb')

LOG = Logger.new(File.join(FP_ROOT,'..','..', 'log', 'file_processor.log'))
LOG.formatter = proc { |severity, datetime, progname, msg|
"[#{datetime}] [#{severity}] #{msg}\n"
}

FTP_FLUX = Dir[File.join(FP_ROOT, 'config', 'ftp', '*')]
FS_FLUX = Dir[File.join(FP_ROOT, 'config', 'fs', '*')]

require File.join(FP_ROOT, 'lib', 'controller.rb')