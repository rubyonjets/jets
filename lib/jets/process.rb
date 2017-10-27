class Jets::Process < Jets::Command
  autoload :Help, 'jets/process/help'
  autoload :ProcessorDeducer, 'jets/process/processor_deducer'
  autoload :BaseProcessor, 'jets/process/base_processor'
  autoload :ControllerProcessor, 'jets/process/controller_processor'

  class_option :verbose, type: :boolean
  class_option :noop, type: :boolean

  desc "controller [event] [context] [handler]", "Processes lambda function from the node shim"
  long_desc Help.controller
  def controller(event, context, handler)
    ControllerProcessor.new(event, context, handler).run
  end
end
