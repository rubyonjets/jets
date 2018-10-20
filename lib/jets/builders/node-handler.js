'use strict';

const shim = require("./handlers/shim.js");

shim.once(); // runs in lambda execution context

exports.hi = (event, context, callback) => {
  shim.request(event, "handlers/controllers/hi_controller.hi", callback);
};

<% @vars.functions.each do |function_name| %>
exports.<%= function_name %> = (event, context, callback) => {
  shim.request(event, "<%= @vars.handler_for(function_name) %>", callback);
};
<% end %>

// for local testing
if (require.main === module) {
  var event = {"hello": "world"};
  var context = {"fake": "context"};
  exports.hi(event, context, (error, message) => {
    console.error("\nLOCAL TESTING OUTPUT");
    if (error) {
      console.error("error message: %o", error);
    } else {
      console.log(JSON.stringify(message)); // stringify
    }
  });
}
