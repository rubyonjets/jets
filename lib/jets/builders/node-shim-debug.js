'use strict';

const spawn = require('child_process').spawn;

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

<% @deducer.functions.each do |function_name| %>
module.exports.<%= function_name %> = (event, context, callback) => {
  const spawn = require('child_process').spawn;
  const ls = spawn('ls', ['-lh', '/var/task']);

  var stdout_buffer = ""/
  ls.stdout.on('data', (data) => {
    console.log(`stdout: ${data}`);
    stdout_buffer += data;
  });

  ls.stderr.on('data', (data) => {
    console.log(`stderr: ${data}`);
  });

  ls.on('close', (code) => {
    console.log(`child process exited with code ${code}`);

    callback(null, stdout_buffer);
  });
}
<% end %>

// for local testing
if (process.platform == "darwin") {
  // fake event and context
  var event = {"hello": "world"}
  // var event = {"body": {"hello": "world"}} // API Gateway wrapper structure
  var context = {"fake": "context"}
  module.exports.<%= @deducer.functions.first %>(event, context, (error, message) => {
    console.error("\nLOCAL TESTING OUTPUT")
    if (error) {
      console.error("error message: %o", error)
    } else {
      console.error("success message %o", message)
      // console.log(JSON.stringify(message)) // stringify
    }
  })
}
