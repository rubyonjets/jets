'use strict';

exports.handle = function(event, context, callback) {
    var body = {'message': 'hi from node'};
    var response = {
      statusCode: "200",
      headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*'
      },
      body: JSON.stringify(body)
    };
    callback(null, response);
};

// if (require.main === module) {
//     console.log('called directly');
// } else {
//     console.log('required as a module');
// }