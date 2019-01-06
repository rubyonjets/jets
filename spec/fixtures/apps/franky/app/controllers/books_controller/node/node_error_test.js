'use strict';

exports.handler = function(event, context, callback) {
    INTENTIONAL_NODE_ERROR
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
