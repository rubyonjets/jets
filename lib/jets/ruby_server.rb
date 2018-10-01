require 'socket'
require 'json'
require 'stringio'

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

      # Reaching here means we'll run the server in the "background"
      pid = Process.fork
      if pid.nil?
        # we're in the child process
        serve
      else
        # we're in the parent process
        # Only start megamode rack server when in background mode, otherwise user is expected to start
        # that server independently.
        start_rack_server
        # Detach main jets ruby server
        Process.detach(pid) # dettached but still in the "foreground" since server loop runs in the foreground
      end
    end

    # Megamode support
    def start_rack_server
      pid = Process.fork
      if pid.nil?
        # we're in the child process
        Jets::Rack::Server.start
        sleep 10
        # TODO: Block until server has been confirmed started successfully
        # ...
      else
        # we're in the parent process
        Process.detach(pid) # dettached but still in the "foreground" since server loop runs in the foreground
      end
    end

    # runs in the child process
    def serve
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
