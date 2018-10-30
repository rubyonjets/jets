'use strict';

const shim = require("handlers/shim.js");

shim.once(); // runs in lambda execution context

<% @vars.functions.each do |function_name| -%>
exports.<%= function_name %> = shim.handler("<%= @vars.handler_for(function_name) %>");
<% end -%>
