require 'active_support/core_ext/hash'
require 'yaml'

class Jets::Cfn
  class Builder
    autoload :Helpers, "jets/cfn/builder/helpers"
    autoload :ParentTemplate, "jets/cfn/builder/parent_template"
    autoload :AppTemplate, "jets/cfn/builder/app_template"
    autoload :AppInfo, "jets/cfn/builder/app_info"
  end
end
