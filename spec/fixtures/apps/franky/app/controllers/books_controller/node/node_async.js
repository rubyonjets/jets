'use strict';

exports.handler = async function(event, context) {
    var body = {'message': 'hi from node'};
    var response = {
      statusCode: "200",
      headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*'
      },
      body: JSON.stringify(body)
    };
    return(response);
   // or
   // throw new Error("some error type”);
}
