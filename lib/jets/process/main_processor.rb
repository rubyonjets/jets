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

Jets.boot # TODO: Can Jets.boot be called Jets in the run method?

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
    #   ControllerDeducer.new("handlers/controllers/posts.create").delegate_class
    #   delegate_class: PostsController
    #
    delegate_class = Jets::Process::Deducer.new(handler).delegate_class
    deducer = delegate_class.new(handler) # IE: PostDeducer.new(handler)
    begin
      # Example of generated code:
      # Controllers:
      #   require "app/controllers/application_controller"
      #   require "app/controllers/posts_controller.rb"
      # Jobs:
      #   require "app/jobs/application_controller"
      #   require "app/jobs/sleep_job.rb"

      result = instance_eval(deducer.code, deducer.path)
      # result = instance_eval("PostsController.new(event, context).create", "app/controllers/posts_controller.rb")
      #
      # Example of generated code:
      #
      # Controllers:
      #   result = PostsController.new(event, context).create
      # Jobs:
      #   result = SleepJob.new(event, context).perform

      # Puts the return value of user's code to stdout because this is
      # what eventually gets used by API Gateway.
      # Explicitly using $stdout since puts redirected to $stderr.
      #
      # JSON.dump is pretty robust.  If it cannot dump the structure into a
      # json string, it just dumps it to a plain text string.
      $stdout.puts JSON.dump(result) # only place where we write to stdout.
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
