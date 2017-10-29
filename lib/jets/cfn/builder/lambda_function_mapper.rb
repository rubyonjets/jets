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
  end
end