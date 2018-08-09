'use strict';

const spawn = require('child_process').spawn;
const fs = require('fs');

function once() {
  // Uncomment fake run once locally. No need to do this on real lambda environment.
  // var filename = '/tmp/once.txt';
  // if (fs.existsSync(filename)) {
  //   return;
  // }
  // fs.closeSync(fs.openSync(filename, 'w'));

  // start tcp server in the background proess
  const subprocess = spawn('bin/ruby_server', {
    detached: true,
    stdio: 'ignore'
  });
  subprocess.on('error', function(err) {
    console.error('bin/ruby_server error', err);
  });

  subprocess.unref();
}

once();

// Once hooked up to API Gateway can use the curl command to test:
// curl -s -X POST -d @event.json https://endpoint | jq .

// Filters out lines so only the error lines remain.
// Uses the "RubyError: " marker to find the starting error lines.
//
// Input: String
// random line
// RubyError: RuntimeError: error in submethod
// line1
// line2
// line3
//
// Output: String
// RubyError: RuntimeError: error in submethod
// line1
// line2
// line3
function filterErrorLines(text) {
  var lines = text.split("\n")
  var markerIndex = lines.findIndex(line => line.startsWith("RubyError: ") )
  lines = lines.filter((line, index) => index >= markerIndex )
  return lines.join("\n")
}

// Produces an Error object that displays in the AWS Lambda test console nicely.
// The backtrace are the ruby lines, not the nodejs shim error lines.
// The json payload in the Lambda console looks something like this:
//
// {
//   "errorMessage": "RubyError: RuntimeError: error in submethod",
//   "errorType": "RubyError",
//   "stackTrace": [
//     [
//       "line1",
//       "line2",
//       "line3"
//     ]
//   ]
// }
//
// Input: String
// RubyError: RuntimeError: error in submethod
// line1
// line2
// line3
//
// Output: Error object
// { RubyError: RuntimeError: error in submethod
// line1
// line2
// line3 name: 'RubyError' }
function customError(text) {
  text = filterErrorLines(text) // filter for error lines only
  var lines = text.split("\n")
  var message = lines[0]
  var error = new Error(message)
  error.name = message.split(':')[0]
  error.stack = lines.slice(0, lines.length-1) // drop final empty line
                  .map(e => e.replace(/^\s+/g,'')) // trim leading whitespaces
                  .join("\n")
  return error
}

////////////////////////////
// main logic for handler
const net = require('net');
const PORT = 8080;
const HOST = '127.0.0.1';

function request(event, handler, callback) {
  console.error("event");
  console.error(event);
  var client = new net.Socket();
  client.connect(PORT, HOST, function() {
    console.error('Node Connected');
    client.write(JSON.stringify(event));
    client.write("\r\n") // important: \r\n is how server knows input is done
    client.write(handler);
    client.write("\r\n") // important: \r\n is how server knows input is done
  });

  client.on('data', function(buffer) {
  	console.error('Node Received2: ' + buffer);
    // console.error(callback)
    // TODO: figure out callback(error);
    // HERE'S WHERE TO HANDLE CALLBACK(ERROR)
    var resp = JSON.parse(buffer.toString());
    callback(null, resp);
    client.destroy(); // kill client after server's response
  });

  client.on('close', function() {
  	console.error('Node Connection closed');
  });

  client.on('error', function(error) {
    console.error("Node Error %o", error);
    console.error("Node retrying request call");
    setTimeout(function() { request(event, handler, callback) }, 1000);
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
  exports.hot(event, context, (error, message) => {
    console.error("\nLOCAL TESTING OUTPUT")
    if (error) {
      console.error("error message: %o", error)
    } else {
      console.log(JSON.stringify(message)) // stringify
    }
  })
}
