# Converts a Jets::Route to a CloudFormation Jets::Resource::ApiGateway::Method resource
module Jets::Resource::ApiGateway
  class Method < Jets::Resource::Base
    include Authorization

    # also delegate permission for a method
    delegate :permission, to: :resource

    # route - Jets::Route
    def initialize(route)
      @route = route
    end

    def definition
      {
        method_logical_id => {
          type: "AWS::ApiGateway::Method",
          properties: props
        }
      }
    end

    def props
      props = {
        resource_id: "!Ref #{resource_id}",
        rest_api_id: "!Ref #{RestApi.logical_id}",
        http_method: @route.method,
        request_parameters: {},
        authorization_type: authorization_type,
        api_key_required: api_key_required?,
        integration: {
          integration_http_method: "POST",
          type: "AWS_PROXY",
          uri: "!Sub arn:aws:apigateway:${AWS::Region}:lambda:path/2015-03-31/functions/${{namespace}LambdaFunction.Arn}/invocations"
        },
        method_responses: []
      }
      props[:authorizer_id] = authorizer_id if authorizer_id
      props[:authorization_scopes] = authorization_scopes if authorization_scopes

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
      http_verb = @route.method.downcase
      [path, "{namespace}_#{http_verb}_api_method"].compact.join('_')
    end

    def replacements
      # mimic task to grab replacements, we want the namespace to be the lambda function's namespace
      resources = [definition]
      task = Jets::Lambda::Task.new(@route.controller_name, @route.action_name,
               resources: resources)
      task.replacements
    end

    def cors
      Cors.new(@route)
    end
    memoize :cors

  private

    def controller_klass
      @controller_klass ||= "#{controller_name}_controller".camelize.constantize
    end

    def controller_name
      @controller_name ||= @route.to.split('#').first
    end

    def resource_id
      @route.path == '' ?
       "RootResourceId" :
       Jets::Resource.truncate_id(resource_logical_id.camelize, "ApiResource")
    end

    # Example: Posts
    def resource_logical_id
      camelized_path.underscore
    end

    def camelized_path
      path = @route.path
      path = "homepage" if path == ''
      path.gsub('/','_').gsub(':','').gsub('*','').gsub('.','').camelize
    end
  end
end
