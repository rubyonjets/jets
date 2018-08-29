# Implements:
#   initialize
#   policy_name
#
module Jets::Cfn::TemplateBuilders::IamPolicy
  class ApplicationPolicy < BasePolicy
    def initialize
      setup
      @definitions = Jets.config.iam_policy # config.iam_policy contains definitions
    end

    # Example: PostsControllerPolicy or SleepJobPolicy
    # Note: There is no "method" in the name
    def policy_name
      "ApplicationPolicy"
    end
  end
end