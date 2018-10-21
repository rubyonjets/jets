'use strict';

const shim = require("handlers/shim.js");

shim.once(); // runs in lambda execution context
<% @vars.functions.each do |function_name| %>
exports.<%= function_name %> = (event, context, callback) => {
  shim.request(event, "<%= @vars.handler_for(function_name) %>", callback);
};
<% end %>
