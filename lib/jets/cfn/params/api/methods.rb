module Jets::Cfn::Params::Api
  class Methods < Base
    # interface method
    def build
      @params.merge!(RestApi: "!GetAtt ApiGateway.Outputs.RestApi") # common
      @template[:Resources].each do |logical_id, resource|
        create_params_from_resource(resource)
      end
    end

    def create_params_from_resource(resource)
      case resource[:Type]
      when "AWS::ApiGateway::Method"
        # function name
        create_function_name_param(resource)
        # authorizer id
        create_authorizer_param(resource)
        # resource id
        resource_id = resource[:Properties][:ResourceId].sub("!Ref ", "")
        @params.merge!(resource_id => api_method_stack_value(resource_id))
      when "AWS::Lambda::Permission"
        # function name
        function_name = resource[:Properties][:FunctionName].sub("!Ref ", "")
        @params.merge!(function_name => controller_stack_value(function_name))
      end
    end

    def create_authorizer_param(resource)
      authorizer_id_ref = resource[:Properties][:AuthorizerId]
      return unless authorizer_id_ref
      authorizer_id = authorizer_id_ref.sub("!Ref ", "")
      @params.merge!(authorizer_id => api_authorizer_stack_value(authorizer_id))
    end

    # IE: !GetAtt MainAuthorizer.Outputs.MainAuthorizerProtectAuthorizer
    def api_authorizer_stack_value(authorizer_id)
      stack = authorizer_id.sub(/(.*?)Authorizer.*Authorizer$/, '\1') # IE: Main
      stack += "Authorizer" # IE: MainAuthorizer
      "!GetAtt #{stack}.Outputs.#{authorizer_id}"
    end

    def create_function_name_param(resource)
      # Type can be: AWS_PROXY or MOCK (cors)
      return unless resource[:Properties][:Integration][:Type] == "AWS_PROXY"
      uri = resource[:Properties][:Integration][:Uri]
      md = uri.match(%r|functions/\${(.*)}/invocations|)
      function_name = md[1]
      @params.merge!(function_name => controller_stack_value(function_name))
    end

    # function_name: UpControllerIndexLambdaFunction
    def controller_stack_value(function_name)
      controller = function_name.sub(/Controller.*/, "Controller")
      # IE: !GetAtt UpController.Outputs.UpControllerIndexLambdaFunction
      "!GetAtt #{controller}.Outputs.#{function_name}"
    end

    def api_method_stack_value(resource_id)
      # IE: !GetAtt ApiResources1.Outputs.UpApiResource
      api_stack = if resource_id == "RootResourceId"
            "ApiGateway"
          else
            Jets::Cfn::Params::Api::Resources.stack_logical_id(resource_id)
          end
      "!GetAtt #{api_stack}.Outputs.#{resource_id}"
    end
  end
end

