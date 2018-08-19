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
    def logical_id
      "#{@app_class}_#{@task.meth}_iam_role".camelize
    end

    def role_name
      "#{@app_class}_#{@task.meth}_iam_role".underscore.dasherize
    end
  end
end
