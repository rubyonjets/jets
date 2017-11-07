require 'active_support/core_ext/hash'
require 'yaml'

class Jets::Cfn
  class Mappers
    # used in the parent_template.rb
    autoload :ChildMapper, "jets/cfn/mappers/child_mapper"
    autoload :ControllerMapper, "jets/cfn/mappers/controller_mapper"
    autoload :JobMapper, "jets/cfn/mappers/job_mapper"
    autoload :ApiGatewayMapper, "jets/cfn/mappers/api_gateway_mapper"
    autoload :ApiGatewayDeploymentMapper, "jets/cfn/mappers/api_gateway_deployment_mapper"
    # used in the child_template.rb
    autoload :GatewayMethodMapper, "jets/cfn/mappers/gateway_method_mapper"
    autoload :GatewayResourceMapper, "jets/cfn/mappers/gateway_resource_mapper"
    autoload :LambdaFunctionMapper, "jets/cfn/mappers/lambda_function_mapper"

    autoload :EventsRuleMapper, "jets/cfn/mappers/events_rule_mapper"
  end
end
