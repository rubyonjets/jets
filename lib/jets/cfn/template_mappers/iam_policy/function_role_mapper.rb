# Implements:
#
#   initialize
#   iam_policy
#   managed_iam_policy
#   logical_id
#   role_name
#
module Jets::Cfn::TemplateMappers::IamPolicy
  class FunctionRoleMapper < BasePolicyMapper
    def initialize(task)
      @task = task
      @app_class = task.class_name.to_s
      # IE: @app_class: PostsController, HardJob, Hello, HelloFunction
    end

    def iam_policy
      return unless @task.iam_policy

      Jets::Cfn::TemplateBuilders::IamPolicy::FunctionRole.new(@task)
    end
    memoize :iam_policy

    def managed_iam_policy
      return unless @task.managed_iam_policy

      Jets::Cfn::TemplateBuilders::ManagedIamPolicy::FunctionRole.new(@task)
    end
    memoize :managed_iam_policy

    # Example: PostsControllerShowLambdaFunction
    # There should be no namespace in the logical_id.
    def logical_id
      classify_name("#{@app_class}_#{@task.meth}_iam_role")
    end

    # There should be namespace in the role_name.
    def role_name
      classify_name("#{namespace}_#{@app_class}_#{@task.meth}_iam_role").underscore.dasherize
    end
  end
end
