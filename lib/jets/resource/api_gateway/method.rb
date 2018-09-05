require "active_support/core_ext/object"

# Converts a Jets::Route to a CloudFormation Jets::Resource::ApiGateway::Method resource
module Jets::Resource::ApiGateway
  class Method < Jets::Resource::Base
    # also delegate permission for a method
    delegate :permission,
             to: :resource

    # route - Jets::Route
    def initialize(route)
      @route = route
    end

    def definition
      {
        method_logical_id => {
          type: "AWS::ApiGateway::Method",
          properties: {
            resource_id: "!Ref #{resource_id}",
            rest_api_id: "!Ref RestApi",
            http_method: @route.method,
            request_parameters: {},
            authorization_type: "NONE",
            integration: {
              integration_http_method: "POST",
              type: "AWS_PROXY",
              uri: "!Sub arn:aws:apigateway:${AWS::Region}:lambda:path/2015-03-31/functions/${{namespace}LambdaFunction.Arn}/invocations"
            },
            method_responses: []
          }
        }
      }
    end

    def method_logical_id
      "{namespace}_api_method"
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
    def resource_id
      @route.path == '' ?
       "RootResourceId" :
       "#{resource_logical_id.camelize}ApiResource"
    end

    # Example: Posts
    def resource_logical_id
      camelized_path.underscore
    end

    def camelized_path
      path = @route.path
      path = "homepage" if path == ''
      path.gsub('/','_').gsub(':','').gsub('*','').camelize
    end
  end
end
