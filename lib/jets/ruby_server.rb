require 'socket'
require 'json'

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
      $stdout.sync = true
      Jets.boot # outside of child process for COW

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

      # Reaching here mean we'll run the server in the background
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
      puts "TCPServer started on port #{PORT}"
      input_completed = false
      loop do
        event, handler = nil, nil
        client = server.accept    # Wait for a client to connect
        unless input_completed
          event = client.gets.strip # text
          # puts event # uncomment for debugging, Jets has changed stdout to stderr
          handler = client.gets.strip # text
          # puts handler # uncomment for debugging, Jets has changed stdout to stderr
          input_completed = true
        end

        begin
          result = Jets::Processors::MainProcessor.new(
            event,
            '{}', # context
            handler).run
        rescue Exception => e
          result = {
            "stackTrace" => e.backtrace,
            "errorMessage" => e.message,
            "errorType" => "RubyError",
          }
        end

        client.puts(result)
        client.close
        input_completed = false
      end
    end

    def self.run
      new.run
    end
  end
end

