const spawn = require('child_process').spawn;

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
sh("node", ["--version"])
sh("uptime")
sh("pwd")
sh("ls", ["bin/ruby_wrapper"])
sh("bin/some_command")
setTimeout(function() {
  console.log('This will run after the timer.');
}, 5000);
sh("bin/ruby_wrapper", ["-v"])

exports.hot = function(event, context, callback) {
   callback(null, "some success message");
}


// module.exports.hot = (event, context, callback) => {
//   console.log('Received event:', JSON.stringify(event, null, 2));
//   var ruby = spawn("bin/ruby_wrapper", args);
//   var stdout_buffer = ""; // stdout buffer
//   ruby.stdout.on('data', function(data) {
//     stdout_buffer += data;
//   });
//   var stderr_buffer = "";
//   ruby.stderr.on('data', function(data) {
//     stderr_buffer += data
//     process.stderr.write(data)
//   });
//   ruby.on('close', function(exit_code) {
//     if (exit_code == 0) {
//       var result;
//       try {
//         result = JSON.parse(stdout_buffer)
//       } catch(e) {
//         // if json cannot be parse assume simple text output intended
//         process.stderr.write("WARN: error parsing json, assuming plain text is desired.")
//         result = stdout_buffer
//       }
//       callback(null, result);
//     } else {
//       var error = customError(stderr_buffer)
//       callback(error);
//     }
//   });
// }


// //////////////////////////////////////
// // Server code
// // start server in the background
// const spawn = require('child_process').spawn;
// const subprocess = spawn('bin/ruby_wrapper', ['simple.rb'], {
//   detached: true,
//   stdio: 'ignore'
// });

// subprocess.unref();

// //////////////////////////////////////
// // Client connect
// var net = require('net');
// const PORT = 8080
// const HOST = '127.0.0.1'

// console.log("hi1");
// var client = new net.Socket();
// console.log("hi2");
// client.connect(PORT, HOST, function() {
//   console.log('Connected');
//   client.write('Hello, server! Love, Client.');
//   // client.destroy(); // close the connection right after sending data
// });

// client.on('data', function(data) {
// 	console.log('Received: ' + data);
// 	client.destroy(); // kill client after server's response
// });

// client.on('close', function() {
// 	console.log('Connection closed');
// });
