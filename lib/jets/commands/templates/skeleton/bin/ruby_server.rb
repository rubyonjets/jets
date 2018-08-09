require 'socket'

# https://ruby-doc.org/stdlib-2.3.0/libdoc/socket/rdoc/TCPServer.html
# https://stackoverflow.com/questions/806267/how-to-fire-and-forget-a-subprocess
pid = Process.fork
if pid.nil? then
  server = TCPServer.new 8080 # Server bind to port 8080
  loop do
    client = server.accept    # Wait for a client to connect
    client.puts "Hello !"
    client.puts "Time is #{Time.now}"
    client.close
  end
else
  Process.detach(pid)
end