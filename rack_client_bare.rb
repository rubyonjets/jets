require 'socket'

host = 'localhost'     # The web server
port = 9292                           # Default HTTP port
path = "/hi"                 # The file we want

request = "GET #{path} HTTP/1.0\r\n\r\n"

socket = TCPSocket.open(host,port)  # Connect to server
socket.print(request)               # Send request
response = socket.read              # Read complete response
# Split response at first blank line into headers and body
headers,body = response.split("\r\n\r\n", 2)

pp headers
print body                          # And display it



# while line = server.gets
#   puts line
# end

# server.close