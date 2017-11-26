class Jets::Commands::Process < Jets::Commands::Base
  autoload :Help, 'jets/commands/process/help'

  class_option :verbose, type: :boolean
  class_option :noop, type: :boolean

  # Some duplication here but the long_desc help is different enough
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

  desc "function [event] [context] [handler]", "Processes node shim job handler"
  long_desc Help.function
  def function(event, context, handler)
    MainProcessor.new(event, context, handler).run
  end
end
