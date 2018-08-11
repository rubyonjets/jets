'use strict';

const spawn = require('child_process').spawn;
const fs = require('fs');
const TMP_LOG_PATH = '/tmp/shim-subprocess.log';
const subprocess_out = fs.openSync(TMP_LOG_PATH, 'a');
const subprocess_err = fs.openSync(TMP_LOG_PATH, 'a');

function once() {
  // Uncomment fake run once locally. No need to do this on real lambda environment.
  // var filename = '/tmp/once.txt';
  // if (fs.existsSync(filename)) {
  //   return;
  // }
  // fs.closeSync(fs.openSync(filename, 'w'));

  // start tcp server and detach
  const subprocess = spawn('bin/ruby_server', {
    detached: true,
    stdio: [ 'ignore', subprocess_out, subprocess_err ]
  });
  subprocess.on('error', function(err) {
    log('bin/ruby_server error', err);
  });

  subprocess.on('close', function(exit_code) {
    log("Subprocess was shut down or deattached!");
  });

  // prevent the parent from waiting for a subprocess to exit
  // https://nodejs.org/api/child_process.html
  subprocess.unref();
}

once();

// Produces an Error object that displays in the AWS Lambda test console nicely.
// The backtrace are the ruby lines, not the nodejs shim error lines.
// The json payload in the Lambda console looks something like this:
//
//   {
//     "errorMessage": "RubyError: RuntimeError: error in submethod",
//     "errorType": "RubyError",
//     "stackTrace": [
//       [
//         "line1",
//         "line2",
//         "line3"
//       ]
//     ]
//   }
//
function customError(resp) {
  var name = resp["errorType"]
  var message = resp["errorMessage"]
  var lines = resp["stackTrace"]

  var error = new Error(message)
  error.name = name
  error.stack = lines.join("\n")
  return error
}

// Not logging to stdout because when testing this shim locally the stdout output
// messes up a pipe to jq.
function log(text) {
  log(text);
}

////////////////////////////
// main logic for handler
const net = require('net');
const PORT = 8080;
const HOST = '127.0.0.1';

function request(event, handler, callback) {
  log("event:");
  log(event);
  var client = new net.Socket();
  client.connect(PORT, HOST, function() {
    log('Connected to socket');
    client.write(JSON.stringify(event));
    client.write("\r\n") // important: \r\n is how server knows input is done
    client.write(handler);
    client.write("\r\n") // important: \r\n is how server knows input is done
  });

  client.on('data', function(buffer) {
  	log('Received data from socket: ' + buffer);
    var resp = JSON.parse(buffer.toString());
    if (resp["errorMessage"]) {
      // Customize error object for lambda format
      var error = customError(resp)
      callback(error);
    } else {
      callback(null, resp);
    }
    client.destroy(); // kill client after server's response
  });

  client.on('close', function() {
  	log('Socket connection closed');
  });

  client.on('error', function(error) {
    log("Socket error %o", error);
    log("Retrying request");
    setTimeout(function() {
      if (fs.existsSync(TMP_LOG_PATH)) {
        var contents = fs.readFileSync(TMP_LOG_PATH, 'utf8');
        log("subprocess output:");
        log(contents);
      }
      request(event, handler, callback);
    }, 500);
  });
};

<% @deducer.functions.each do |function_name| %>
exports.<%= function_name %> = (event, context, callback) => {
  request(event, "<%= @deducer.handler_for(function_name) %>", callback);
}
<% end %>

// for local testing
if (require.main === module) {
  // fake event and context
  var event = {"hello": "world"}
  // var event = {"body": {"hello": "world"}} // API Gateway wrapper structure
  var context = {"fake": "context"}
  exports.<%= @deducer.functions.first %>(event, context, (error, message) => {
    log("\nLOCAL TESTING OUTPUT")
    if (error) {
      console.log("error message: %o", error)
    } else {
      console.log(JSON.stringify(message)) // stringify
    }
  })
}
