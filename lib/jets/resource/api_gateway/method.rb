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
        "#{method_logical_id}ApiMethod" => {
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

    def replacements
      # mimic task to grab replacements
      resources = [definition]
      task = Jets::Lambda::Task.new(@route.controller_name, @route.action_name,
               resources: resources)
      task.replacements
    end
    memoize :replacements

    def cors
      Cors.new(@route)
    end
    memoize :cors

  private
    # Similar path_logical_id method in template_mappers/gateway_resource_mapper.rb
    # Example: PostsGet
    def method_logical_id
      path = camelized_path
      path + "#{@route.method.to_s.downcase.camelize}"
    end

    def resource_id
      @route.path == '' ?
       "RootResourceId" :
       "#{resource_logical_id}ApiResource"
    end

    # Example: Posts
    def resource_logical_id
      camelized_path
    end

    def camelized_path
      path = @route.path
      path = "homepage" if path == ''
      path.gsub('/','_').gsub(':','').gsub('*','').camelize
    end
  end
end
