module Jets::Cfn::Resource::Lambda
  class Function < Jets::Cfn::Base
    MAX_FUNCTION_NAME_SIZE = 64
    include Environment

    def initialize(definition)
      @definition = definition
      @app_class = definition.class_name.to_s
    end

    def definition
      {
        function_logical_id => {
          Type: "AWS::Lambda::Function",
          Properties: combined_properties
        }
      }
    end

    # Examples:
    #   one_lambda_per_controller PostsControllerLambdaHandlerLambdaFunction
    #   one_lambda_per_method     PostsControllerIndexLambdaFunction
    def function_logical_id
      "{namespace}LambdaFunction"
    end

    def replacements
      @definition.replacements # has namespace replacement
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
        Code: {
          S3Bucket: "!Ref S3Bucket",
          S3Key: code_s3_key
        },
        Role: "!Ref IamRole",
        Environment: { Variables: environment },
      }

      application_config = camelize(Jets.application.config.function.to_h)
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
      klass = Jets::Klass.from_definition(@definition)

      class_properties = lookup_class_properties(klass)
      if assign_iam_role?(klass)
        iam_policy = Jets::Cfn::Resource::Iam::ClassRole.new(klass)
        class_properties[:Role] = "!GetAtt #{iam_policy.logical_id}.Arn"
      end

      camelize(class_properties)
    end

    # The IAM Role is built in the same nested template but determination of
    # whether or not to assign the IAM Role is determined by the inheritance.
    # The merging of permissions is already handled by Resource::Iam::*Role classes.
    # This also avoids having to pass Application IAM role around.
    def assign_iam_role?(klass)
      assign = false
      while klass && klass != Object
        if klass&.build_class_iam?
          assign = true
          break
        end
        klass = klass.superclass
      end
      assign
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
      properties = @definition.properties
      if @definition.build_function_iam?
        iam_policy = Jets::Cfn::Resource::Iam::FunctionRole.new(@definition)
        properties[:Role] = "!GetAtt #{iam_policy.logical_id}.Arn"
      end
      camelize(properties)
    end

    # Properties managed by Jets merged with finality.
    def finalize_properties!(props)
      handler = full_handler(props)
      runtime = get_runtime(props)
      description = get_descripton(props)
      managed = {
        Handler: handler,
        Runtime: runtime,
        Description: description,
      }
      managed[:FunctionName] = function_name if function_name
      layers = get_layers(runtime)
      managed[:Layers] = layers if layers
      props.merge!(managed)
    end

    def get_layers(runtime)
      return nil unless runtime =~ /^ruby/ || runtime =~ /^provided/
      return Jets.config.lambda.layers if Jets.config.pro.disable

      ["!Ref GemLayer"] + Jets.config.lambda.layers
    end

    def get_runtime(props)
      # Only allow custom runtime for ruby so polymorphic support works for python and node
      if @definition.lang == :ruby
        props[:Runtime] || default_runtime
      else
        default_runtime
      end
    end

    def default_runtime
      self.class.default_runtimes[@definition.lang]
    end

    # Also used by jets/stack/main/dsl/lambda.rb
    def self.default_runtimes
      {
        node: "nodejs18.x",
        python: "python3.10",
        ruby: Jets.ruby_runtime,
      }
    end

    def default_handler
      map = {
        node: @definition.full_handler(:handler), # IE: handlers/controllers/posts/show.handler
        python: @definition.full_handler(:lambda_handler), # IE: handlers/controllers/posts/show.lambda_handler
        ruby: handler, # IE: handlers/controllers/posts_controllers.index
      }
      map[@definition.lang]
    end

    def handler
      handler_value(@definition.meth)  # IE: handlers/controllers/posts_controllers.index
    end

    # Used for node-shim also
    def handler_value(meth)
      "handlers/#{@definition.type.pluralize}/#{@app_class.underscore}.#{meth}"
    end

    # Ensure that the handler path is normalized.
    def full_handler(props)
      if props[:Handler]
        handler_value(props[:Handler])
      else
        default_handler
      end
    end

    def code_s3_key
      checksum = Jets::Builders::Md5.checksums["stage/code"]
      "jets/code/code-#{checksum}.zip" # s3_key
    end

    # Examples:
    #   "#{Jets.project_namespace}-sleep_job-perform"
    #   "demo-dev-sleep_job-perform"
    def function_name
      return if ENV['JETS_RESET'] # reset mode, let CloudFormation manage the function name
      # Example values:
      #   @app_class: admin/pages_controller
      #   @definition.meth: index
      #   method: admin/pages_controller
      #   method: admin-pages_controller-index

      method = @app_class.underscore
      method = method.gsub('/','-').gsub(/[^0-9a-z\-_]/i, '')
      unless one_lambda_per_controller?
        method += "-#{@definition.meth}"
      end
      function_name = "#{Jets.project_namespace}-#{method}"

      # Returns nil if function name is too long.
      # CloudFormation will managed the the function name in this case.
      # A pretty function name won't be generated but the deploy will be successful.
      function_name.size > MAX_FUNCTION_NAME_SIZE ? nil : function_name
    end

    def get_descripton(props)
      props[:Description] || default_description
    end

    # Example values:
    #   @app_class: Admin/PagesController
    #   @definition.meth: index
    # Returns:
    #   Admin/PagesController
    # or
    #   Admin/PagesController#index
    def default_description
      if one_lambda_per_controller?
        "#{@app_class}"
      else
        "#{@app_class}##{@definition.meth}"
      end
    end

    def one_lambda_per_controller?
      Jets.one_lambda_per_controller? && @app_class.to_s.ends_with?("Controller")
    end
  end
end
