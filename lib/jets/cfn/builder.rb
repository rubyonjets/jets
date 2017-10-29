require 'active_support/core_ext/hash'
require 'yaml'

class Jets::Cfn
  class Builder
    autoload :Helpers, "jets/cfn/builder/helpers"
    autoload :ParentTemplate, "jets/cfn/builder/parent_template"
    autoload :AppTemplate, "jets/cfn/builder/app_template"
    autoload :AppInfo, "jets/cfn/builder/app_info"
    autoload :GatewayMethodMapper, "jets/cfn/builder/gateway_method_mapper"
    autoload :GatewayResourceMapper, "jets/cfn/builder/gateway_resource_mapper"
    autoload :LambdaFunctionMapper, "jets/cfn/builder/lambda_function_mapper"
    autoload :ApiGatewayTemplate, "jets/cfn/builder/api_gateway_template"
  end
end
