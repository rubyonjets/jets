require 'socket'
require 'json'
require 'stringio'

# Save copy of old stdout, since Jets.boot messes with it.
# So we can use $normal_stdout.puts for debugging.
$normal_stdout ||= $stdout
$normal_stderr ||= $stderr

# https://ruby-doc.org/stdlib-2.3.0/libdoc/socket/rdoc/TCPServer.html
# https://stackoverflow.com/questions/806267/how-to-fire-and-forget-a-subprocess
#
# There's a generated bin/ruby_server which calls bin/ruby_server.rb as part of the
# starter project template. Usage:
#
#    bin/ruby_server # background
#    FOREGROUND=1 bin/ruby_server # foreground
#
module Jets
  class RubyServer
    PORT = 8080

    def run
      Jets.boot(stringio: true) # outside of child process for COW
      Jets.eager_load!

      # INT - ^C
      trap('INT') do
        puts "Shutting down ruby_server.rb..."
        sleep 0.1
        exit
      end
      if ENV['FOREGROUND'] # Usage above
        serve
        return
      end

      # Reaching here means we'll run the server in the background
      pid = Process.fork
      if pid.nil?
        serve
      else
        # parent process
        Process.detach(pid)
      end
    end

    def serve
      # child process
      server = TCPServer.new(8080) # Server bind to port 8080
      puts "Ruby server started on port #{PORT}" if ENV['FOREGROUND'] || ENV['JETS_DEBUG'] || ENV['C9_USER']

      loop do
        client = server.accept    # Wait for a client to connect

        input_completed, event, handler = nil, nil, nil
        unless input_completed
          event = client.gets.strip # text
          # puts event # uncomment for debugging, Jets has changed stdout to stderr
          handler = client.gets.strip # text
          # puts handler # uncomment for debugging, Jets has changed stdout to stderr
          input_completed = true
        end

        result = event['_prewarm'] ?
          prewarm_request(event) :
          standard_request(event, '{}', handler)

        Jets::IO.flush # flush output and write to disk for node shim

        client.puts(result)
        client.close
      end
    end

    def prewarm_request(event)
      # JSON.dump("prewarmed_at" => Time.now.to_s)
      Jets.increase_prewarm_count
      Jets.logger.info("Prewarm request")
      %Q|{"prewarmed_at":"#{Time.now.to_s}"}| # raw json for speed
    end

    def standard_request(event, context, handler)
      Jets::Processors::MainProcessor.new(
        event,
        context,
        handler).run
    rescue Exception => e
      JSON.dump(
        "stackTrace" => e.backtrace,
        "errorMessage" => e.message,
        "errorType" => "RubyError",
      )
    end

    def self.run
      new.run
    end
  end
end
