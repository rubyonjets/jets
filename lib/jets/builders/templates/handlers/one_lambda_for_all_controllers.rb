require "bundler/setup"
require "jets"
Jets.once  # runs once in lambda execution context

def lambda_handler(event:, context:)
  if event['_prewarm']
    Jets.process(event, context, nil)
    return
  end

  <% if @vars.process_type == "controller" -%>
  route = Jets::Router.find_route_by_event(event)
  controller = route.controller_name
  action = route.action_name
  if Jets.config.cfn.build.routes == "one_apigw_method_for_all_routes"
    event["pathParameters"] = route.rebuild_path_parameters(event) # override
  end
<% end -%>
  Jets.process(event, context, "handlers/controllers/#{controller}.#{action}")
end
<% if ENV['JETS_DEBUG_HANDLER'] %>
<%# JETS_DEBUG_HANDLER=1 jets build %>
if __FILE__ == $0
  event = {
    "path" => "/posts",
    "httpMethod" => "GET",
    "headers" => {
      "Host" => "localhost:8888",
    }
  }
  lambda_handler(event: event, context: {})
end
<% end %>
