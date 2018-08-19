# Implements:
#
#   initialize
#   iam_policy
#   logical_id
#   role_name
#
module Jets::Cfn::TemplateMappers::IamPolicy
  class ApplicationPolicyMapper < BasePolicyMapper
    def initialize; end # does nothing

    def iam_policy
      Jets::Cfn::TemplateBuilders::IamPolicy::ApplicationPolicy.new
    end
    memoize :iam_policy

    # Example: PostsControllerLambdaFunction
    # Note there are is no "Show" action in the name
    def logical_id
      # "#{namespace}_application_iam_role".camelize
      "IamRole"
    end

    def role_name
      "#{namespace}_application_iam_role".underscore.dasherize
    end
  end
end