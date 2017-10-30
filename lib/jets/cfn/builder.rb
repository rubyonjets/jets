require 'active_support/core_ext/hash'
require 'yaml'

class Jets::Cfn
  class Builder
    autoload :Helpers, "jets/cfn/builder/helpers"

    autoload :ParentTemplate, "jets/cfn/builder/parent_template"
    autoload :ChildTemplate, "jets/cfn/builder/child_template"
    autoload :ApiGatewayTemplate, "jets/cfn/builder/api_gateway_template"

    autoload :ChildMapper, "jets/cfn/builder/child_mapper"
    autoload :GatewayMethodMapper, "jets/cfn/builder/gateway_method_mapper"
    autoload :GatewayResourceMapper, "jets/cfn/builder/gateway_resource_mapper"
    autoload :GatewayDeploymentMapper, "jets/cfn/builder/gateway_deployment_mapper"
    autoload :LambdaFunctionMapper, "jets/cfn/builder/lambda_function_mapper"
  end
end
