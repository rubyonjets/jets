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
      result = instance_eval(deducer.code, deducer.path)
      # result = PostsController.process(event, context, "create")

      Jets.increase_call_count
      if result.is_a?(Hash) && result["headers"]
        result["headers"]["x-jets-call-count"] = Jets.call_count
        result["headers"]["x-jets-prewarm-count"] = Jets.prewarm_count
      end

      result
    rescue Exception => e
      unless ENV['TEST']
        # Customize error message slightly so nodejs shim can process the
        # returned error message.
        # The "RubyError: " is a marker that the javascript shim scans for.
        $stderr.puts("RubyError: #{e.class}: #{e.message}") # js needs this as the first line
        backtrace = e.backtrace.map {|l| "  #{l}" }
        $stderr.puts(backtrace)
        # No need to having error in stderr above anymore because errors are handled in memory
        # at ruby_server.rb but keeping around for posterity.
      end

      Jets.report_exception(e)
      raise(e) # raise error to ruby_server.rb to rescue and handle
    end
  end
end
