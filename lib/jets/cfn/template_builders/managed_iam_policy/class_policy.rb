# Implements:
#   initialize
#
module Jets::Cfn::TemplateBuilders::ManagedIamPolicy
  class ClassPolicy < BasePolicy
    def initialize(app_class)
      @definitions = app_class.managed_iam_policy || [] # managed_iam_policy contains definitions
    end
  end
end