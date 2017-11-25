require 'json'

# Node shim calls this class to process both controllers and jobs

# Global overrides for Lambda processing
$stdout.sync = true
# This might seem weird but we want puts to write to stderr which is set in
# the node shim to write to stderr.  This directs the output to Lambda logs.
# Printing to stdout can managle up the payload returned from Lambda function.
# This is not desired if you want to return say a json payload to API Gateway
# eventually.
def puts(text)
  $stderr.puts(text)
end
def print(text)
  $stderr.print(text)
end

class Jets::Process::MainProcessor
  attr_reader :event, :context, :handler
  def initialize(event, context, handler)
    # assume valid json from Lambda
    @event = JSON.parse(event)
    @context = JSON.parse(context)
    @handler = handler
  end

  def run
    # Use the handler to deduce app code to run.
    # Example handlers: handlers/controllers/posts.create, handlers/jobs/sleep.perform
    #
    #   deducer = Jets::Process::Deducer.new("handlers/controllers/posts.create")
    #
    deducer = Jets::Process::Deducer.new(handler)
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

      # Puts the return value of project code to stdout because this is
      # what eventually gets used by API Gateway.
      # Explicitly using $stdout since puts has been redirected to $stderr.
      #
      # JSON.dump is pretty robust.  If it cannot dump the structure into a
      # json string, it just dumps it to a plain text string.
      text = Jets::Util.normalize_result(result)
      # TODO: figure a way to silence this output for specs wihtout breaking process_spec.rb
      $stdout.puts text # only place where we write to stdout.
      text
    rescue Exception => e
      # Customize error message slightly so nodejs shim can process the
      # returned error message.
      # The "RubyError: " is a marker that the javascript shim scans for.
      $stderr.puts("RubyError: #{e.class}: #{e.message}") # js needs this as the first line
      backtrace = e.backtrace.map {|l| "  #{l}" }
      $stderr.puts(backtrace)
      # $stderr.puts("END OF RUBY OUTPUT")
      exit 1 # instead of re-raising to control the error backtrace output
    end
  end

end
