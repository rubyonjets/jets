require 'active_support/core_ext/hash'
require 'yaml'

class Jets::Cfn
  class TemplateMappers
    # used in the parent_template.rb
    autoload :ChildMapper, "jets/cfn/template_mappers/child_mapper"
    autoload :ControllerMapper, "jets/cfn/template_mappers/controller_mapper"
    autoload :JobMapper, "jets/cfn/template_mappers/job_mapper"
    autoload :FunctionMapper, "jets/cfn/template_mappers/function_mapper"

    autoload :ApiGatewayMapper, "jets/cfn/template_mappers/api_gateway_mapper"
    autoload :ApiGatewayDeploymentMapper, "jets/cfn/template_mappers/api_gateway_deployment_mapper"
    # used in the child_template.rb
    autoload :GatewayMethodMapper, "jets/cfn/template_mappers/gateway_method_mapper"
    autoload :GatewayResourceMapper, "jets/cfn/template_mappers/gateway_resource_mapper"
    autoload :LambdaFunctionMapper, "jets/cfn/template_mappers/lambda_function_mapper"

    autoload :EventsRuleMapper, "jets/cfn/template_mappers/events_rule_mapper"
  end
end
