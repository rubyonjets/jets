require 'socket'
require 'json'
require 'jets'

$stdout.sync = true
PORT = 8080

# https://ruby-doc.org/stdlib-2.3.0/libdoc/socket/rdoc/TCPServer.html
# https://stackoverflow.com/questions/806267/how-to-fire-and-forget-a-subprocess

Jets.boot # outside of child process for COW
pid = Process.fork
if pid.nil?
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
        "errorMessage": e.message,
        "errorType": "RubyError",
      }
    end

    client.puts(result)
    client.close
    input_completed = false
  end
else
  # parent process
  Process.detach(pid)
end