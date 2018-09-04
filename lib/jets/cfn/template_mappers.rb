require 'active_support/core_ext/hash'
require 'yaml'

class Jets::Cfn
  class TemplateMappers
    autoload :IamPolicy, "jets/cfn/template_mappers/iam_policy"
  end
end
