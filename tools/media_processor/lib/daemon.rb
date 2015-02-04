require File.join(File.dirname(__FILE__), 'media_processor.rb')

Signal.trap('INT') { @controller.halt('INT') }
Signal.trap('TERM') { @controller.halt('TERM') }

@controller = Controller.new()
@controller.run(PROCESSOR_CONFIG[:controller][:workers])
