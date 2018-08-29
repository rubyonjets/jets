# Implements:
#   initialize
#
module Jets::Cfn::TemplateBuilders::ManagedIamPolicy
  class FunctionPolicy < BasePolicy
    def initialize(task)
      @definitions = task.managed_iam_policy || [] # managed_iam_policy contains definitions
    end
  end
end