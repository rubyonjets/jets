module Jets::Cfn::Resource::One
  class Function < Jets::Cfn::Resource::Lambda::Function
    include Jets::Cfn::Resource::Lambda::Function::Environment

    # override to use the same function name for all controllers
    def initialize
    end

    # override
    def function_logical_id
      "JetsControllerLambdaFunction"
    end

    # override
    def combined_properties
      props = env_properties
        .deep_merge(global_properties)
        .deep_merge(application_controller_properties)
      finalize_properties!(props)
    end

    def application_controller_properties
      klass = ApplicationController
      return {} unless klass.build_class_iam?

      class_properties = lookup_class_properties(klass)
      iam_policy = Jets::Cfn::Resource::Iam::ClassRole.new(klass)
      class_properties[:Role] = "!GetAtt #{iam_policy.logical_id}.Arn"
      camelize(class_properties)
    end

    # Properties managed by Jets merged with finality.
    def finalize_properties!(props)
      handler = "handlers/controller.lambda_handler"
      runtime = get_runtime(props)
      description = "Jets Lambda function for all controllers"
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

    # override
    def get_runtime(props)
      props[:Runtime] || Jets.ruby_runtime
    end

    # Examples:
    #   "#{Jets.project_namespace}-sleep_job-perform"
    #   "demo-dev-sleep_job-perform"
    def function_name
      return if ENV['JETS_RESET'] # reset mode, let CloudFormation manage the function name
      "#{Jets.project_namespace}-controller"
    end

    # override
    def replacements
      {}
    end
  end
end
