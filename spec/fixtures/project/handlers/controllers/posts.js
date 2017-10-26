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


module.exports.create = (event, context, callback) => {
  // Command: bin/lam process controller [event] [context] [handler]
  var args = [
    "process",
    "controllers",     // controllers
    JSON.stringify(event),      // event
    JSON.stringify(context),    // context
    "handlers/controllers/posts.create" // IE: handlers/controllers/posts.update
  ]
  var ruby = spawn("bin/lam", args);

  // string concatation in javascript is faster than array concatation
  // http://bit.ly/2gBMDs6
  var stdout_buffer = ""; // stdout buffer
  // In the processor_command we do NOT call puts directly and write to stdout
  // because it will mess up the eventual response that we want API Gateway to
  // process.
  // The Lambda prints out function to whatever the return value the ruby method
  ruby.stdout.on('data', function(data) {
    // Not using console.log because it decorates output with a newline.
    //
    // Uncomment process.stdout.write to see stdout streamed for debugging.
    // process.stdout.write(data)
    stdout_buffer += data;
  });

  // react to potential errors
  var stderr_buffer = "";
  ruby.stderr.on('data', function(data) {
    // not using console.error because it decorates output with a newline
    stderr_buffer += data
    process.stderr.write(data)
  });

  //finalize when ruby process is done.
  ruby.on('close', function(exit_code) {
    // http://docs.aws.amazon.com/lambda/latest/dg/nodejs-prog-model-handler.html#nodejs-prog-model-handler-callback

    // succcess
    if (exit_code == 0) {
      var result
      try {
        result = JSON.parse(stdout_buffer)
      } catch(e) {
        // if json cannot be parse assume simple text output intended
        process.stderr.write("WARN: error parsing json, assuming plain text is desired.")
        result = stdout_buffer
      }
      callback(null, result);

      // callback(null, stdout_buffer);
    } else {

      // TODO: if this works, allow a way to not decorate the error in case
      // it actually errors in javascript land
      // Customize error object with ruby error info
      var error = customError(stderr_buffer)
      callback(error);
      // console.log("error!")
    }
  });
}

module.exports.update = (event, context, callback) => {
  // Command: bin/lam process controller [event] [context] [handler]
  var args = [
    "process",
    "controllers",     // controllers
    JSON.stringify(event),      // event
    JSON.stringify(context),    // context
    "handlers/controllers/posts.update" // IE: handlers/controllers/posts.update
  ]
  var ruby = spawn("bin/lam", args);

  // string concatation in javascript is faster than array concatation
  // http://bit.ly/2gBMDs6
  var stdout_buffer = ""; // stdout buffer
  // In the processor_command we do NOT call puts directly and write to stdout
  // because it will mess up the eventual response that we want API Gateway to
  // process.
  // The Lambda prints out function to whatever the return value the ruby method
  ruby.stdout.on('data', function(data) {
    // Not using console.log because it decorates output with a newline.
    //
    // Uncomment process.stdout.write to see stdout streamed for debugging.
    // process.stdout.write(data)
    stdout_buffer += data;
  });

  // react to potential errors
  var stderr_buffer = "";
  ruby.stderr.on('data', function(data) {
    // not using console.error because it decorates output with a newline
    stderr_buffer += data
    process.stderr.write(data)
  });

  //finalize when ruby process is done.
  ruby.on('close', function(exit_code) {
    // http://docs.aws.amazon.com/lambda/latest/dg/nodejs-prog-model-handler.html#nodejs-prog-model-handler-callback

    // succcess
    if (exit_code == 0) {
      var result
      try {
        result = JSON.parse(stdout_buffer)
      } catch(e) {
        // if json cannot be parse assume simple text output intended
        process.stderr.write("WARN: error parsing json, assuming plain text is desired.")
        result = stdout_buffer
      }
      callback(null, result);

      // callback(null, stdout_buffer);
    } else {

      // TODO: if this works, allow a way to not decorate the error in case
      // it actually errors in javascript land
      // Customize error object with ruby error info
      var error = customError(stderr_buffer)
      callback(error);
      // console.log("error!")
    }
  });
}


// for local testing
if (process.platform == "darwin") {
  // fake event and context
  var event = {"hello": "world"}
  // var event = {"body": {"hello": "world"}} // API Gateway wrapper structure
  var context = {"fake": "context"}
  module.exports.create(event, context, (error, message) => {
    console.error("\nLOCAL TESTING OUTPUT")
    if (error) {
      console.error("error message: %o", error)
    } else {
      console.error("success message %o", message)
      // console.log(JSON.stringify(message)) // stringify
    }
  })
}
