# Implements:
#
#   initialize
#   iam_policy
#   logical_id
#   role_name
#
module Jets::Cfn::TemplateMappers::IamPolicy
  class ClassPolicyMapper < BasePolicyMapper
    def initialize(app_class)
      @app_class = app_class
      # IE: @app_class: PostsController, HardJob, Hello, HelloFunction
    end

    def iam_policy
      Jets::Cfn::TemplateBuilders::IamPolicy::ClassPolicy.new(@app_class)
    end
    memoize :iam_policy

    # Example: PostsControllerLambdaFunction
    # Note there are is no "Show" action in the name
    # There should be no namespace in the logical_id.
    def logical_id
      "#{@app_class}_iam_role".camelize
    end

    # There should be namespace in the role_name.
    def role_name
      "#{namespace}_#{@app_class}_iam_role".underscore.dasherize
    end
  end
end