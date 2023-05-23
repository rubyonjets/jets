require "bundler/setup"
require "jets"
Jets.once  # runs once in lambda execution context

<% @vars.functions.each do |function_name|
  handler = @vars.handler_for(function_name)
  meth = handler.split('.').last
-%>
def <%= meth -%>(event:, context:)
<% if @vars.process_type == "controller" -%>
  if Jets.config.cfn.build.routes == "one_apigw_method_for_all_routes"
    route = Jets::Router.find_route_by_event(event)
    event["pathParameters"] = route.rebuild_path_parameters(event) # override
  end
<% end -%>
  Jets.process(event, context, "<%= handler -%>")
end
<% end %>