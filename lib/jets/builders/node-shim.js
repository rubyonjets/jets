'use strict';

//////////////////////////////////////
// Server code
// start server in the background
const spawn = require('child_process').spawn;
const subprocess = spawn('bin/ruby_wrapper', ['simple.rb'], {
  detached: true,
  stdio: 'ignore'
});

subprocess.unref();

//////////////////////////////////////
// Client connect
var net = require('net');
const PORT = 8080
const HOST = '127.0.0.1'

console.log("hi1");
var client = new net.Socket();
console.log("hi2");
client.connect(PORT, HOST, function() {
  console.log('Connected');
  client.write('Hello, server! Love, Client.');
  // client.destroy(); // close the connection right after sending data
});

client.on('data', function(data) {
	console.log('Received: ' + data);
	client.destroy(); // kill client after server's response
});

client.on('close', function() {
	console.log('Connection closed');
});
