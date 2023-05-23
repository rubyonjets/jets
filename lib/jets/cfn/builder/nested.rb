# Note: compose implemented by the classes that include this
class Jets::Cfn::Builder
  class Nested
    include Interface

    # The app_class is can be a controller, job or anonymous function class.
    # IE: PostsController, HardJob
    def initialize(app_class)
      @app_class = app_class
      @template = ActiveSupport::HashWithIndifferentAccess.new(Resources: {})
    end

    # interface method
    def template_path
      Jets::Names.app_template_path(@app_class)
    end

    def add_common_parameters
      common_parameters = Jets::Cfn::Params::Common.parameters
      common_parameters.each do |k,_|
        add_parameter(k)
      end

      depends_on_params.each do |output_key, _|
        add_parameter(output_key)
      end
    end

    def depends_on_params
      return {} if Jets.one_lambda_for_all_controllers? && @app_class.to_s.ends_with?("Controller")
      return {} if @app_class.is_a?(Hash)
      return {} unless @app_class.depends_on
      depends = Jets::Stack::Depends.new(@app_class.depends_on)
      depends.params
    end

    def add_functions
      validate_function_names!
      if Jets.one_lambda_per_controller? && @app_class.to_s.ends_with?("Controller")
        one_lambda_per_controller
      else
        one_lambda_per_method
      end
    end

    def one_lambda_per_method
      add_class_iam_policy
      @app_class.definitions.each do |definition|
        add_function(definition)
        add_function_iam_policy(definition)
      end
    end

    def one_lambda_per_controller
      add_class_iam_policy
      definition = Jets::Lambda::Definition.new(@app_class, "lambda_handler",
        lang: :ruby,
      )
      add_function(definition)
      unless Jets::Router.no_routes?
        controller = Jets::Cfn::Resource::Lambda::Function::Controller.new(definition)
        add_resource(controller.permission)
      end
    end

    def add_function(definition)
      resource = Jets::Cfn::Resource::Lambda::Function.new(definition)
      add_resource(resource)
      # apigw lambda permission is also added to the controller template next to the function
      route = Jets::Router.find_by_definition(definition)
      if route
        # Creates a permission more directly to set principal apigateway.amazonaws.com
        method = Jets::Cfn::Resource::ApiGateway::Method.new(route)
        add_resource(method.permission)
      end
    end

    # routes scoped to this controller template.
    def scoped_routes
      @routes ||= Jets::Router.routes.select do |route|
        route.controller_name == @app_class.to_s
      end
    end

    def add_class_iam_policy
      return unless build_class_iam_policy?

      resource = Jets::Cfn::Resource::Iam::ClassRole.new(@app_class)
      add_resource(resource)
    end

    def build_class_iam_policy?
      should_build = false
      klass = @app_class
      while klass && klass != Object
        if klass&.build_class_iam?
          should_build = true
          break
        end
        klass = klass.superclass
      end
      should_build
    end

    def add_function_iam_policy(definition)
      return unless definition.build_function_iam?

      resource = Jets::Cfn::Resource::Iam::FunctionRole.new(definition)
      add_resource(resource)
    end

    def validate_function_names!
      invalids = @app_class.definitions.reject do |definition|
        definition.meth.to_s =~ /^[a-zA-Z][a-zA-Z0-9_]/
      end
      return if invalids.empty?
      list = invalids.map do |definition|
        "    #{definition.class_name}##{definition.meth}" # IE: PostsController#index
      end.join("\n")
      puts "ERROR: Detected invalid AWS Lambda function names".color(:red)
      puts <<~EOL
        Lambda function names must start with a letter and can only contain letters, numbers, and underscores.
        Invalid function names:

        #{list}
      EOL
      exit 1
    end
  end
end
