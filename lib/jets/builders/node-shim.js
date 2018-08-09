const spawn = require('child_process').spawn;
const fs = require('fs');

function once() {
  // fake run once
  var filename = '/tmp/once.txt';
  if (fs.existsSync(filename)) {
     return;
  }
  fs.closeSync(fs.openSync(filename, 'w'));

  function sh(command, args) {
    if (args == null) {
       args = []
    }
    // console.log("args %o", args);
    var child;
    child = spawn(command, args)
    child.stdout.on('data', function(data) {
       console.log('stdout: ' + data);
    });
    child.stderr.on('data', function(data) {
       console.log('stderr: ' + data);
    });
    child.on('close', function(exit_code) {
      console.log("exit code %", exit_code);
    });
    child.on('error', function(err) {
      console.log('child error', err);
    });
  }
  // sh("node", ["--version"])
  // sh("uptime")
  // sh("pwd")
  // sh("ls", ["bin/ruby_wrapper"])
  // sh("whoami")
  // sh("bin/ruby_wrapper", ["-v"])

  //////////////////////////////////////
  // Server code
  // start server in the background
  const subprocess = spawn('bin/ruby_server', {
    detached: true,
    stdio: 'ignore'
  });
  subprocess.on('error', function(err) {
    console.log('bin/ruby_server error', err);
  });

  subprocess.unref();
}

once();

////////////////////////////
// handler
const net = require('net');
const PORT = 8080
const HOST = '127.0.0.1'

function request(callback) {
  console.log("hi1");
  console.log(callback);
  var client = new net.Socket();
  console.log("hi2");
  client.connect(PORT, HOST, function() {
    console.log('Connected');
    client.write('Hello, server! Love, Client.');
    // client.destroy(); // close the connection right after sending data
  });

  client.on('data', function(buffer) {
  	console.log('Received2: ' + buffer);
    // console.log(callback)
    callback(null, buffer.toString());
    client.destroy(); // kill client after server's response
  });

  client.on('close', function() {
  	console.log('Connection closed');
  });

  client.on('error', function(error) {
    console.log("Error %o", error);
    console.log("retrying request call");
    setTimeout(function() { request(callback) }, 1000);
  });
};

exports.hot = function(event, context, callback) {
  // if (typeof callback == "undefined") {
  //   var callback = function(error, data) {
  //     console.log("fake callback3 %o", data);
  //     return(data);
  //   }
  // }
  // callback(null, "some success message");

  request(callback);
}

if (require.main === module) {
  exports.hot({}, {}, function() {});
}