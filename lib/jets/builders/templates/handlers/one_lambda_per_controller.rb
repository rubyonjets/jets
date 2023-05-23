require "bundler/setup"
require "jets"
Jets.once  # runs once in lambda execution context

<%# # IE: handlers/controllers/up_controller.index -%>
<% handler = @vars.handler_base + '.#{action}' -%>
def lambda_handler(event:, context:)
  if event['_prewarm']
    Jets.process(event, context, nil)
    return
  end

<% if @vars.process_type == "controller" -%>
  if Jets.config.cfn.build.routes == "one_apigw_method_for_all_routes"
    route = Jets::Router.find_route_by_event(event)
    event["pathParameters"] = route.rebuild_path_parameters(event) # override
  end
<% end -%>
  Jets.process(event, context, "<%= handler -%>")
end
