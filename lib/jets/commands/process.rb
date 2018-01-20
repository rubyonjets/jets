module Jets::Commands
  class Process < Jets::Commands::Base
    class_option :verbose, type: :boolean
    class_option :noop, type: :boolean

    # Some duplication here but the long_desc help is different enough
    desc "controller [event] [context] [handler]", "Processes node shim controller handler", hide: true
    long_desc Help.text('process:controller')
    def controller(event, context, handler)
      Jets::Processors::MainProcessor.new(event, context, handler).run
    end

    desc "job [event] [context] [handler]", "Processes node shim job handler", hide: true
    long_desc Help.text('process:job')
    def job(event, context, handler)
      Jets::Processors::MainProcessor.new(event, context, handler).run
    end

    desc "rule [event] [context] [handler]", "Processes node shim rule handler", hide: true
    long_desc Help.text('process:rule')
    def rule(event, context, handler)
      Jets::Processors::MainProcessor.new(event, context, handler).run
    end

    desc "function [event] [context] [handler]", "Processes node shim job handler", hide: true
    long_desc Help.text('process:function')
    def function(event, context, handler)
      Jets::Processors::MainProcessor.new(event, context, handler).run
    end
  end
end
