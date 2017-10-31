require 'active_support/core_ext/hash'
require 'yaml'

class Jets::Cfn
  class Builder
    autoload :Helpers, "jets/cfn/builder/helpers"

    autoload :ParentTemplate, "jets/cfn/builder/parent_template"
    autoload :ChildTemplate, "jets/cfn/builder/child_template"
    autoload :ControllerTemplate, "jets/cfn/builder/controller_template"
    autoload :JobTemplate, "jets/cfn/builder/job_template"
    autoload :ApiGatewayTemplate, "jets/cfn/builder/api_gateway_template"
    autoload :ApiGatewayDeploymentTemplate, "jets/cfn/builder/api_gateway_deployment_template"

    # used in the parent_template.rb
    autoload :ChildMapper, "jets/cfn/builder/child_mapper"
    autoload :ControllerMapper, "jets/cfn/builder/controller_mapper"
    autoload :JobMapper, "jets/cfn/builder/job_mapper"
    autoload :ApiGatewayMapper, "jets/cfn/builder/api_gateway_mapper"
    autoload :ApiGatewayDeploymentMapper, "jets/cfn/builder/api_gateway_deployment_mapper"
    # used in the child_template.rb
    autoload :GatewayMethodMapper, "jets/cfn/builder/gateway_method_mapper"
    autoload :GatewayResourceMapper, "jets/cfn/builder/gateway_resource_mapper"
    autoload :LambdaFunctionMapper, "jets/cfn/builder/lambda_function_mapper"
  end
end
