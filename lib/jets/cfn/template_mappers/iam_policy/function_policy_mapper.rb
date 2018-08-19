# Implements:
#
#   initialize
#   iam_policy
#   logical_id
#   role_name
#
module Jets::Cfn::TemplateMappers::IamPolicy
  class FunctionPolicyMapper < BasePolicyMapper
    def initialize(task)
      @task = task
      @app_class = task.class_name.to_s
      # IE: @app_class: PostsController, HardJob, Hello, HelloFunction
    end

    def iam_policy
      Jets::Cfn::TemplateBuilders::IamPolicy::FunctionPolicy.new(@task)
    end
    memoize :iam_policy

    # Example: PostsControllerShowLambdaFunction
    # There should be no namespace in the logical_id.
    def logical_id
      "#{@app_class}_#{@task.meth}_iam_role".camelize
    end

    # There should be namespace in the role_name.
    def role_name
      "#{namespace}_#{@app_class}_#{@task.meth}_iam_role".underscore.dasherize
    end
  end
end
