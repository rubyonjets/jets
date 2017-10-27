require 'active_support/core_ext/hash'
require 'yaml'

class Jets::Cfn
  class Builder
    autoload :Helpers, "jets/cfn/builder/helpers"
    autoload :Parent, "jets/cfn/builder/parent"
    autoload :AppStack, "jets/cfn/builder/app_stack"
    autoload :AppInfo, "jets/cfn/builder/app_info"
    autoload :BaseStack, "jets/cfn/builder/base_stack"
    autoload :BaseInfo, "jets/cfn/builder/base_info"
  end
end
