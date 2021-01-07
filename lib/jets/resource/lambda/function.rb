module Jets::Resource::Lambda
  class Function < Jets::Resource::Base
    include Environment

    def initialize(task)
      @task = task
      @app_class = task.class_name.to_s
    end

    def definition
      {
        function_logical_id => {
          type: "AWS::Lambda::Function",
          properties: combined_properties
        }
      }
    end

    def function_logical_id
      "{namespace}_lambda_function".underscore
    end

    def replacements
      @task.replacements # has namespace replacement
    end

    def combined_properties
      props = env_properties
        .deep_merge(global_properties)
        .deep_merge(class_properties)
        .deep_merge(function_properties)
      finalize_properties!(props)
    end

    # Global properties example:
    # jets defaults are in jets/default/application.rb.
    # Your application's default config/application.rb then get used. Example:
    #
    #   Jets.application.configure do
    #     config.function = ActiveSupport::OrderedOptions.new
    #     config.function.timeout = 30
    #     config.function.runtime = "nodejs8.10"
    #     config.function.memory_size = 1536
    #   end
    def global_properties
      baseline = {
        code: {
          s3_bucket: "!Ref S3Bucket",
          s3_key: code_s3_key
        },
        role: "!Ref IamRole",
        environment: { variables: environment },
      }

      application_config = Jets.application.config.function.to_h
      baseline.merge(application_config)
    end

    # Class properties example:
    #
    #   class PostsController < ApplicationController
    #     class_timeout 22
    #     ...
    #   end
    #
    # Also handles iam policy override at the class level. Example:
    #
    #   class_iam_policy("logs:*")
    #
    def class_properties
      # klass is PostsController, HardJob, GameRule, Hello or HelloFunction
      klass = Jets::Klass.from_task(@task)

      class_properties = lookup_class_properties(klass)
      if klass.build_class_iam?
        iam_policy = Jets::Resource::Iam::ClassRole.new(klass)
        class_properties[:role] = "!GetAtt #{iam_policy.logical_id}.Arn"
      end

      class_properties
    end

    # Accounts for inherited class_properties
    def lookup_class_properties(klass)
      all_classes = []
      while klass != Object
        all_classes << klass
        klass = klass.superclass
      end
      class_properties = {}
      # Go back down class heirachry top to down
      all_classes.reverse.each do |k|
        class_properties.merge!(k.class_properties)
      end
      class_properties
    end

    # Function properties example:
    #
    # class PostsController < ApplicationController
    #   timeout 18
    #   def index
    #     ...
    #   end
    #
    # Also handles iam policy override at the function level. Example:
    #
    #   iam_policy("ec2:*")
    #   def new
    #     render json: params.merge(action: "new")
    #   end
    #
    def function_properties
      properties = @task.properties
      if @task.build_function_iam?
        iam_policy = Jets::Resource::Iam::FunctionRole.new(@task)
        properties[:role] = "!GetAtt #{iam_policy.logical_id}.Arn"
      end
      properties
    end

    # Properties managed by Jets with merged with finality.
    def finalize_properties!(props)
      handler = full_handler(props)
      runtime = get_runtime(props)
      managed = {
        handler: handler,
        runtime: runtime,
        description: description,
      }
      managed[:function_name] = function_name if function_name
      layers = get_layers(runtime)
      managed[:layers] = layers if layers
      props.merge!(managed)
    end

    def get_layers(runtime)
      return nil unless runtime =~ /^ruby/
      ["!Ref GemLayer"] + Jets.config.lambda.layers
    end

    def get_runtime(props)
      props[:runtime] || default_runtime
    end

    def default_runtime
      map = {
        node: "nodejs8.10",
        python: "python3.6",
        ruby: Jets.ruby_runtime,
      }
      map[@task.lang]
    end

    def default_handler
      map = {
        node: @task.full_handler(:handler), # IE: handlers/controllers/posts/show.handler
        python: @task.full_handler(:lambda_handler), # IE: handlers/controllers/posts/show.lambda_handler
        ruby: handler, # IE: handlers/controllers/posts_controllers.index
      }
      map[@task.lang]
    end

    def handler
      handler_value(@task.meth)  # IE: handlers/controllers/posts_controllers.index
    end

    # Used for node-shim also
    def handler_value(meth)
      "handlers/#{@task.type.pluralize}/#{@app_class.underscore}.#{meth}"
    end

    # Ensure that the handler path is normalized.
    def full_handler(props)
      if props[:handler]
        handler_value(props[:handler])
      else
        default_handler
      end
    end

    def code_s3_key
      checksum = Jets::Builders::Md5.checksums["stage/code"]
      "jets/code/code-#{checksum}.zip" # s3_key
    end

    # Examples:
    #   "#{Jets.config.project_namespace}-sleep_job-perform"
    #   "demo-dev-sleep_job-perform"
    def function_name
      # Example values:
      #   @app_class: admin/pages_controller
      #   @task.meth: index
      #   method: admin/pages_controller
      #   method: admin-pages_controller-index
      method = @app_class.underscore
      method = method.gsub('/','-').gsub(/[^0-9a-z\-_]/i, '') + "-#{@task.meth}"
      function_name = "#{Jets.config.project_namespace}-#{method}"
      # Returns nil if function name is too long.
      # CloudFormation will managed the the function name in this case.
      # A pretty function name won't be generated but the deploy will be successful.
      function_name.size > Jets::MAX_FUNCTION_NAME_SIZE ? nil : function_name
    end

    def description
      # Example values:
      #   @app_class: Admin/PagesController
      #   @task.meth: index
      # Returns:
      #   Admin/PagesController#index
      "#{@app_class}##{@task.meth}"
    end
  end
end
