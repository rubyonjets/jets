class Jets::Process < Jets::Command
  autoload :Help, 'jets/process/help'
  autoload :ProcessorDeducer, 'jets/process/processor_deducer'
  autoload :BaseProcessor, 'jets/process/base_processor'
  autoload :ControllerProcessor, 'jets/process/controller_processor'

  class_option :verbose, type: :boolean
  class_option :noop, type: :boolean
  class_option :project_root, desc: "Project folder.  Defaults to current directory", default: "."
  class_option :region, desc: "AWS region"

  desc "create STACK", "create a CloudFormation stack"
  option :randomize_stack_name, type: :boolean, desc: "tack on random string at the end of the stack name", default: nil
  long_desc Help.controller
  def controller(event, context, handler)
    ControllerProcessor.new(event, context, handler).run
  end
end
