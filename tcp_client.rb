# tcp_client.rb
require 'socket'
server = TCPSocket.new 'localhost', 5678

while line = server.gets
  puts line
end

server.close