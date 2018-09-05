require 'active_support/core_ext/hash'
require 'yaml'

class Jets::Cfn
  class Builders
    autoload :Interface, "jets/cfn/builders/interface"
    autoload :ParentBuilder, "jets/cfn/builders/parent_builder"

    # These build the app/controllers, app/jobs, and app/functions
    autoload :BaseChildBuilder, "jets/cfn/builders/base_child_builder"
    autoload :ControllerBuilder, "jets/cfn/builders/controller_builder"
    autoload :JobBuilder, "jets/cfn/builders/job_builder"
    autoload :FunctionBuilder, "jets/cfn/builders/function_builder"
    autoload :RuleBuilder, "jets/cfn/builders/rule_builder"

    autoload :ApiGatewayBuilder, "jets/cfn/builders/api_gateway_builder"
    autoload :ApiDeploymentBuilder, "jets/cfn/builders/api_deployment_builder"
  end
end
