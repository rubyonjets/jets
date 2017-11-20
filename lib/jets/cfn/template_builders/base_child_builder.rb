class Jets::Cfn::TemplateBuilders
  class BaseChildBuilder
    include Interface

    # The app_class is can be a controller or a job class.
    # IE: PostsController, HardJob
    def initialize(app_class)
      @app_class = app_class
      @template = ActiveSupport::HashWithIndifferentAccess.new(Resources: {})
    end

    # template_path is an interface method for Interface module
    def template_path
      Jets::Naming.template_path(@app_class)
    end

    def add_common_parameters
      add_parameter("IamRole", Description: "Iam Role that Lambda function uses.")
      add_parameter("S3Bucket", Description: "S3 Bucket for source code.")
    end

    def add_functions
      @app_class.tasks.each do |task|
        add_function(task)
      end
    end

    def add_function(task)
      builder = FunctionPropertiesBuilder.new(task)
      logical_id = builder.map.logical_id
      add_resource(logical_id, "AWS::Lambda::Function", builder.properties)
    end
  end
end
