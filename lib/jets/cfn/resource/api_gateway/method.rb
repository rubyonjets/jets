# Converts a Jets::Route to a CloudFormation Jets::Cfn::Resource::ApiGateway::Method resource
module Jets::Cfn::Resource::ApiGateway
  class Method < Jets::Cfn::Base
    include Authorization

    # route - Jets::Route
    def initialize(route)
      @route = route
    end

    def definition
      {
        method_logical_id => {
          Type: "AWS::ApiGateway::Method",
          Properties: props
        }
      }
    end

    # Note: The {namespace} in
    #   functions/${{namespace}LambdaFunction.Arn}/invocations
    # is replaced by Jets::Cfn::Resource::Replacer
    #
    #   Jets::Cfn::Resource::ApiGateway::Method
    #     Jets::Cfn::Resource (attributes delegate to resource)
    #     Jets::Cfn::Resource => replacer
    #
    def props
      function_logical_id = Jets.one_lambda_for_all_controllers? ?
          "JetsControllerLambdaFunction" :
          "{namespace}LambdaFunction"

      resource_id = ResourceId.new(@route.path).resource_id
      props = {
        ResourceId: "!Ref #{resource_id}",
        RestApiId: "!Ref #{RestApi.logical_id}",
        HttpMethod: @route.http_method,
        RequestParameters: {},
        AuthorizationType: authorization_type,
        ApiKeyRequired: api_key_required?,
        Integration: {
          IntegrationHttpMethod: "POST",
          Type: "AWS_PROXY",
          Uri: "!Sub arn:aws:apigateway:${AWS::Region}:lambda:path/2015-03-31/functions/${#{function_logical_id}}/invocations"
        },
        MethodResponses: []
      }
      props[:AuthorizerId] = authorizer_id if authorizer_id
      props[:AuthorizationScopes] = authorization_scopes if authorization_scopes

      props
    end

    def method_logical_id
      # https://stackoverflow.com/questions/6104240/how-do-i-strip-non-alphanumeric-characters-from-a-string-and-keep-spaces
      # Add path to the logical id to allow 2 different paths to be connected to the same controller action.
      # Example:
      #
      #   root "jets/public#show"
      #   any "*catchall", to: "jets/public#show"
      #
      # Without the path in the logical id, the logical id would be ShowApiMethod for both routes and only the
      # last one would be created in the CloudFormation template.
      path = @route.path.gsub('*','')
              .gsub(/[^0-9a-z]/i, ' ')
              .gsub(/\s+/, '_')
      path = nil if path == ''
      http_verb = @route.http_method.downcase
      [http_verb, path, "api_method"].compact.join('_')
    end

    def replacements
      # Mimic task to grab replacements
      # Use functions/${namespace} in Uri
      resources = [definition]
      action_name = Jets.one_lambda_per_controller? ? "lambda_handler" : @route.action_name
      task = Jets::Lambda::Definition.new(@route.controller_name, action_name,
               resources: resources)
      task.replacements
    end

  private

    def controller_klass
      @controller_klass ||= "#{controller_name}_controller".camelize.constantize
    end

    def controller_name
      @controller_name ||= @route.to.split('#').first
    end
  end
end
