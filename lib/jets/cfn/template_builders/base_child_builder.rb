class Jets::Cfn::TemplateBuilders
  class BaseChildBuilder
    include Interface

    # The app_klass is can be a controller, job or anonymous function class.
    # IE: PostsController, HardJob
    def initialize(app_klass)
      @app_klass = app_klass
      @template = ActiveSupport::HashWithIndifferentAccess.new(Resources: {})
    end

    # template_path is an interface method for Interface module
    def template_path
      Jets::Naming.template_path(@app_klass)
    end

    def add_common_parameters
      add_parameter("IamRole", Description: "Iam Role that Lambda function uses.")
      add_parameter("S3Bucket", Description: "S3 Bucket for source code.")
    end

    def add_functions
      @app_klass.tasks.each do |task|
        add_function(task)

        if task.iam_policy
          add_iam_policy(task)
        end
      end
    end

    def add_function(task)
      # Examples:
      #   FunctionProperties::RubyBuilder
      #   FunctionProperties::PythonBuilder
      builder_class = "Jets::Cfn::TemplateBuilders::FunctionProperties::#{task.lang.to_s.classify}Builder".constantize
      builder = builder_class.new(task)
      logical_id = builder.map.logical_id
      add_resource(logical_id, "AWS::Lambda::Function", builder.properties)
    end

    def add_iam_policy(task)
      iam_policy = IamPolicy.new(task)
      pp iam_policy.policy_document

      # COPIED FROM GENERATED TEMPLATE, TODO: move into a mapper?
      properties = {
        AssumeRolePolicyDocument: {
          Version: '2012-10-17',
          Statement: [{
            Effect: Allow,
            Principal: {Service: ["lambda.amazonaws.com"],
            Action: ["sts:AssumeRole"]
          }]
        },
        Path: "/",
        RoleName: "TODO: MAP THIS ROLE NAME" # IE: posts-controller-new-iam-role
      }
      properties[:Policies] = [
        PolicyName: iam_policy.policy_name,
        PolicyDocument: iam_policy.policy_document,
      ]
      properties.deep_stringify_keys! # needed?

      logical_id = iam_policy.logical_id
      add_resource(logical_id, "AWS::IAM::Role", properties)
      # TODO: still need to have the funciton now reference this custom role!
      # TODO: what about class level roles then?
    end
  end
end
