require "bundler/setup"
require "jets"
Jets.once  # runs once in lambda execution context

<% @vars.functions.each do |function_name|
  handler = @vars.handler_for(function_name)
  meth = handler.split('.').last
  -%>
def <%= meth -%>(event:, context:)
  ActiveRecord::Base.connection.reconnect! unless ActiveRecord::Base.connection.active?
  Jets.process(event, context, "<%= handler -%>")
ensure
  ActiveRecord::Base.connection.disconnect!
end
<% end %>
