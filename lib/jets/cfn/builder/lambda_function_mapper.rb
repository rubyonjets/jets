class Jets::Cfn::Builder
  class LambdaFunctionMapper
    attr_reader :controller # Example: PostsController
    def initialize(controller, method_name)
      @controller, @method_name = controller.to_s, method_name
    end

    def lambda_function_logical_id
      "#{controller_action}LambdaFunction"
    end

    # Example: PostsControllerIndex
    def controller_action
      "#{@controller}_#{@method_name}".camelize
    end

    ###############################
    def function_name
      method = "#{@controller}_#{@method_name}".underscore.dasherize
      "#{Jets::Config.project_namespace}-#{method}"
    end

    def handler
      underscored = @controller.to_s
                      .sub('Controller', '')
                      .sub('Job', '')
                      .underscore
      "handlers/controllers/#{underscored}.#{@method_name}"
    end

    def code_s3_key
      Jets::Naming.code_s3_key
    end
  end
end