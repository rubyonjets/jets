require 'active_support/core_ext/hash'
require 'yaml'

class Jets::Cfn
  class Builder
    autoload :Helpers, "jets/cfn/builder/helpers"
    autoload :Parent, "jets/cfn/builder/parent"
    autoload :Child, "jets/cfn/builder/child"
    autoload :ChildInfo, "jets/cfn/builder/child_info"
  end
end
