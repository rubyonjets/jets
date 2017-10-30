class Jets::Process < Jets::Command
  autoload :Help, 'jets/process/help'
  autoload :Deducer, 'jets/process/deducer'
  autoload :MainProcessor, 'jets/process/main_processor'

  class_option :verbose, type: :boolean
  class_option :noop, type: :boolean

  desc "controller [event] [context] [handler]", "Processes node shim controller handler"
  long_desc Help.controller
  def controller(event, context, handler)
    MainProcessor.new(event, context, handler).run
  end

  desc "job [event] [context] [handler]", "Processes node shim job handler"
  long_desc Help.job
  def job(event, context, handler)
    MainProcessor.new(event, context, handler).run
  end
end
