# Implements:
#   initialize
#
module Jets::Cfn::TemplateBuilders::ManagedIamPolicy
  class ApplicationPolicy < BasePolicy
    def initialize
      @definitions = Jets.config.managed_iam_policy # config.iam_policy contains definitions
    end
  end
end