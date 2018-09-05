class Jets::Cfn::Builders
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
      add_class_iam_policy
      @app_klass.tasks.each do |task|
        add_function(task)
        add_function_iam_policy(task)
      end
    end

    def add_function(task)
      resource = Jets::Resource::Function.new(task)
      add_resource(resource)
    end

    def add_class_iam_policy
      return unless @app_klass.build_class_iam?

      resource = Jets::Resource::Iam::ClassRole.new(@app_klass)
      add_resource(resource)
    end

    def add_function_iam_policy(task)
      return unless task.build_function_iam?

      resource = Jets::Resource::Iam::FunctionRole.new(task)
      add_resource(resource)
    end
  end
end
