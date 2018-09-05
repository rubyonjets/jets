# Implements:
#   initialize
#
module Jets::Cfn::TemplateBuilders::ManagedIamPolicy
  class ApplicationRole < BasePolicy
    def initialize
      @definitions = Jets.config.managed_iam_policy # config.managed_iam_policy contains definitions
      @definitions = [@definitions].flatten if @definitions
    end
  end
end