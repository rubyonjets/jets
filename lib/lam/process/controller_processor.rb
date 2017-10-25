require_relative "base_processor"

class Lam::Process
  class ControllerProcessor < Lam::Process::BaseProcessor
    def run
      # Use the handler value (ie: posts.create) to infer the user's business
      # code to require and run.
      infer = Infer.new(handler)
      path = infer.controller[:path]
      code = infer.controller[:code]

      begin
        require path  # require "app/controllers/posts_controller.rb"
        # Puts the return value of user's code to stdout because this is
        # what eventually gets used by API Gateway.
        # Explicitly using $stdout since puts redirected to $stderr.

        # result = PostsController.new(event, context).create
        result = instance_eval(code, path)

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
end
