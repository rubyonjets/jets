require "bundler/setup"
require "jets"
Jets.once  # runs once in lambda execution context

<% @vars.functions.each do |function_name| -%>
Jets.handler(self, "<%= @vars.handler_for(function_name) %>")
<% end %>