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

        if iam_policy(task.iam_policy)
          add_iam_policy(task.iam_policy)
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

    def add_iam_policy(iam_policy)
      iam = IamPolicy.new(iam_policy)
      iam.resource
    end
  end
end
