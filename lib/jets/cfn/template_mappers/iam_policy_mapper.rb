class Jets::Cfn::TemplateMappers
  class IamPolicyMapper
    extend Memoist

    def initialize(task)
      @task = task
      @app_class = task.class_name.to_s
      # IE: @app_class: PostsController, HardJob, Hello, HelloFunction
    end

    def iam_policy
      Jets::Cfn::TemplateBuilders::IamPolicy.new(@task)
    end
    memoize :iam_policy

    # Example: SleepJobPerformLambdaFunction
    def logical_id
      "#{@app_class}_#{@task.meth}_iam_role".camelize
    end

    def role_name
      "#{@app_class}_#{@task.meth}_iam_role".underscore.dasherize
    end

    def properties
      properties = {
        AssumeRolePolicyDocument: {
          Version: "2012-10-17",
          Statement: [{
            Effect: "Allow",
            Principal: {Service: ["lambda.amazonaws.com"]},
            Action: ["sts:AssumeRole"]}
          ]},
        Path: "/"
      }
      properties[:Policies] = [
        PolicyName: iam_policy.policy_name,
        PolicyDocument: iam_policy.policy_document,
      ]
      properties[:RoleName] = role_name
      properties.deep_stringify_keys!
      properties
    end
  end
end
