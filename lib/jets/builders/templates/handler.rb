require "bundler/setup"
require "jets"
Jets.once  # runs once in lambda execution context

<% @vars.functions.each do |function_name|
  handler = @vars.handler_for(function_name)
  meth = handler.split('.').last
-%>
def <%= meth -%>(event:, context:)
  Jets.process(event, context, "<%= handler -%>")
end
<% end %>