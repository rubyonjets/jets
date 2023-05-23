require 'json'
require 'stringio'

# Node shim calls this class to process both controllers and jobs
class Jets::Processors::MainProcessor
  attr_reader :event, :context, :handler
  def initialize(event, context, handler)
    @event = event
    @context = context
    @handler = handler
  end

  def run
    # Use the handler to deduce app code to run.
    # Example handlers: handlers/controllers/posts.create, handlers/jobs/sleep.perform
    #
    #   deducer = Jets::Processors::Deducer.new("handlers/controllers/posts.create")
    #
    deducer = Jets::Processors::Deducer.new(handler)
    begin
      # Examples:
      #   deducer.code => PostsController.process(event, context, "show")
      #   deducer.path => app/controllers/posts_controller.rb
      #
      #   deducer.code => HardJob.process(event, context, "dig")
      #   deducer.path => app/jobs/hard_job.rb
      #
      #   deducer.code => HelloFunction.process(event, context, "world")
      #   deducer.path => app/functions/hello.rb
      deducer.load_class
      # result = PostsController.process(event, context, "create")
      result = instance_eval(deducer.code, deducer.path)
      result = HashWithIndifferentAccess.new(result) if result.is_a?(Hash)

      Jets.increase_call_count

      if result.is_a?(Hash) && result["headers"]
        # API Gateway is okay with the header values as Integers but
        # ELBs are more strict about this and require the header values to be Strings
        result["headers"]["x-jets-call-count"] = Jets.call_count.to_s
        result["headers"]["x-jets-prewarm-count"] = Jets.prewarm_count.to_s
      end

      result

    # Additional rescue Exception as a paranoid measure.  We want to make sure
    # that we always report the exception.  This is the last line of defense.
    # Note: This only happens when the code is running in Lambda.
    rescue => exception
      Jets.report_exception(exception)
      raise(exception)
    end
  end
end
