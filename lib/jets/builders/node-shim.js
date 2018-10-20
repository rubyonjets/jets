const TMP_LOG_PATH = '/tmp/shim-subprocess.log';
const JETS_DEBUG = process.env.JETS_DEBUG; // set JETS_DEBUG=1 to see more debugging info
const JETS_OUTPUT = '/tmp/jets-output.log';

const spawn = require('child_process').spawn;
const fs = require('fs');
const readline = require('readline');
const subprocess_out = fs.openSync(TMP_LOG_PATH, 'a');
const subprocess_err = fs.openSync(TMP_LOG_PATH, 'a');
const { exec } = require('child_process');
const AWS = require('aws-sdk/global');
const S3 = require('aws-sdk/clients/s3'); // import individual service
const net = require('net');

////////////////////////////////////////////////////////////////////////////////
// util methods
const sh = async (command, args) => {
  var promise = new Promise(function(resolve, reject) {
    log(`=> ${command}`);
    exec(command, (err, stdout, stderr) => {
      log(`stdout: ${stdout}`);
      log(`stderr: ${stderr}`);
      if (err) {
        resolve({success: false, command: command});
      } else {
        resolve({success: true, command: command});
      }
    });
  });
  return promise;
};

const download = async (bucket, key, dest) => {
  var promise = new Promise(function(resolve, reject) {
    var s3 = new AWS.S3();
    var params = {Bucket: bucket, Key: key};
    var file = require('fs').createWriteStream(dest);
    var stream = s3.getObject(params).createReadStream();
    var pipe = stream.pipe(file);
    file.on('finish', function () {
      resolve({success: true, pipe: pipe});
    });
  });
  return promise;
};

// Clean out files to prevent confusing double output when debugging.
// Also clean out the file whenever done printing out the output.
function truncate(path) {
  if (fs.existsSync(path)) {
    fs.truncateSync(path);
  }
}

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
function rubyError(resp) {
  var name = resp["errorType"];
  var message = resp["errorMessage"];
  var stack = resp["stackTrace"];
  stack.unshift(message); // JS error includes the error message at the top of the stacktrac also
  stack = stack.join("\n");

  var error = new Error(message);
  error.name = name;
  error.stack = stack;
  return error;
}

// On AWS Lambda, we can log to either stdout or stderr and we're okay.
// But locally when we're testing the shim, the log output can mess up piping
// to jq. So not logging to stdout because when testing this shim locally the
// stdout output messes up a pipe to jq.
function log(text, level="info") {
  if (level == "info" && JETS_DEBUG) {
    // only log if JETS_DEBUG is set
    console.error(text);
  } else if (level == "debug") {
    // always log if "debug" passed into method
    console.error(text);
  }
}

////////////////////////////////////////////////////////////////////////////////
// Logic that runs once in the lambda execution context

const downloadTmp = async () => {
  var bucket = '<%= @vars.s3_bucket %>';      // demo-dev-s3bucket-1inlzkvujq8zb
  var key = 'jets/code/<%= @vars.rack_zip %>'; // jets/code/rack-checksum.zip
  var dest = '/tmp/<%= @vars.rack_zip %>';     // /tmp/rack-checksum.zip
  await download(bucket, key, dest);
  await sh(`unzip -qo ${dest} -d /tmp/rack`);
  await sh("ls /tmp/rack*");

  key = 'jets/code/<%= @vars.bundled_zip %>'; // jets/code/bundled-checksum.zip
  dest = '/tmp/<%= @vars.bundled_zip %>';     // /tmp/bundled-checksum.zip
  await download(bucket, key, dest);
  await sh(`unzip -qo ${dest} -d /tmp/bundled`);
  await sh("ls /tmp/bundled*");
};

const rubyServer = () => {
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
};

// once runs in lambda execution context
const once = async () => {
  // Uncomment fake run once locally. No need to do this on real lambda environment.
  // var filename = '/tmp/once.txt';
  // if (fs.existsSync(filename)) {
  //   log("fake run only once. /tmp/once.txt exists. remove to run once again.");
  //   return;
  // }
  // fs.closeSync(fs.openSync(filename, 'w'));

  await downloadTmp();
  // The server related methods are fire and forget.
  // Not using await here because had trouble resolving the promise on client.connect
  rubyServer(); // no await
};

////////////////////////////////////////////////////////////////////////////////
// main logic for handler
function request(event, handler, callback) {
  truncate(JETS_OUTPUT);
  truncate(TMP_LOG_PATH);

  log("event:");
  log(event);
  var client = new net.Socket();
  client.connect(8080, '127.0.0.01', function() {
    log('Connected to socket');
    client.write(JSON.stringify(event));
    client.write("\r\n"); // important: \r\n is how server knows input is done
    client.write(handler);
    client.write("\r\n"); // important: \r\n is how server knows input is done
  });

  // string concatation in javascript is faster than array concatation
  // http://bit.ly/2gBMDs6
  var stdout_buffer = ""; // stdout buffer
  client.on('data', function(buffer) {
  	log('Received data from socket: ' + buffer);
    stdout_buffer += buffer;
  });

  client.on('close', function() {
  	log('Socket connection closed');
  	// If server is not yet running, socket immediately closes and stdout_buffer
  	// is still empty. Return right away for this case, so request can retry.
  	if (stdout_buffer == "") {
  	  return;
  	}

    if (fs.existsSync(JETS_OUTPUT)) {
      // Thanks: https://stackoverflow.com/questions/6156501/read-a-file-one-line-at-a-time-in-node-js
      var rd = readline.createInterface({
        input: fs.createReadStream(JETS_OUTPUT),
        // output: process.stdout,
        console: false
      });

      rd.on('line', function(line) {
        // Important to use console.error in case locally testing shim or we see
        // stdout "twice", once from here and once from ruby-land and it's confusing.
        // AWS lambda will write console.error and console.log to CloudWatch.
        console.error(line); // output to AWS Lambda Logs
      });

      truncate(JETS_OUTPUT); // done reporting output, clear out file again
    }

    var resp = JSON.parse(stdout_buffer);
    if (resp["errorMessage"]) {
      // Customize error object for lambda format
      var error = rubyError(resp);
      callback(error);
    } else {
      callback(null, resp);
    }
    client.destroy(); // kill client after server's response
  });

  client.on('error', function(error) {
    log("Socket error:");
    log(error);
    log("Retrying request");
    setTimeout(function() {
      if (fs.existsSync(TMP_LOG_PATH)) {
        var contents = fs.readFileSync(TMP_LOG_PATH, 'utf8');
        if (contents != "") {
          log("subprocess output:", "debug");
          log(contents, "debug");
        }
      }
      truncate(TMP_LOG_PATH);

      log("Retrying request NOW");
      request(event, handler, callback);
    }, 500);
  });
}

module.exports = {
  request: request,
  once: once
};