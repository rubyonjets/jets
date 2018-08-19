require 'active_support/core_ext/hash'
require 'yaml'

class Jets::Cfn
  # TODO: These builder classes sort of all work a little differently and a bit of a mess. Refactor this.
  class TemplateBuilders
    autoload :Interface, "jets/cfn/template_builders/interface"
    autoload :ParentBuilder, "jets/cfn/template_builders/parent_builder"

    # These build the app/controllers, app/jobs, and app/functions
    autoload :BaseChildBuilder, "jets/cfn/template_builders/base_child_builder"
    autoload :ControllerBuilder, "jets/cfn/template_builders/controller_builder"
    autoload :JobBuilder, "jets/cfn/template_builders/job_builder"
    autoload :FunctionBuilder, "jets/cfn/template_builders/function_builder"
    autoload :RuleBuilder, "jets/cfn/template_builders/rule_builder"

    autoload :ApiGatewayBuilder, "jets/cfn/template_builders/api_gateway_builder"
    autoload :ApiGatewayDeploymentBuilder, "jets/cfn/template_builders/api_gateway_deployment_builder"

    # separate beasts:
    autoload :FunctionProperties, "jets/cfn/template_builders/function_properties" # sort of a builder
    autoload :IamPolicy, "jets/cfn/template_builders/iam_policy" # resource only
  end
end
