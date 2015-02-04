require File.join(File.dirname(__FILE__), 'file_processor.rb')

Signal.trap('INT') { @controller.halt('INT') }
Signal.trap('TERM') { @controller.halt('TERM') }

@controller = Controller.new
@controller.run( File.join(FP_ROOT, 'config', 'ftp.yml') )
