require 'active_support/core_ext/hash'
require 'yaml'

class Jets::Cfn
  class Builders
    autoload :Helpers, "jets/cfn/builders/helpers"
    autoload :ParentTemplate, "jets/cfn/builders/parent_template"
    autoload :ChildTemplate, "jets/cfn/builders/child_template"
    autoload :ControllerTemplate, "jets/cfn/builders/controller_template"
    autoload :JobTemplate, "jets/cfn/builders/job_template"
    autoload :ApiGatewayTemplate, "jets/cfn/builders/api_gateway_template"
    autoload :ApiGatewayDeploymentTemplate, "jets/cfn/builders/api_gateway_deployment_template"
  end
end
