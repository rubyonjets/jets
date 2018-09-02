# Converts a Jets::Route to a CloudFormation resource
module Jets::Resource
  class Route
    autoload :Attributes, 'jets/resource/route/attributes'
    autoload :Cors, 'jets/resource/route/cors'

    extend Memoist

    # route - Jets::Route
    def initialize(route)
      @route = route
    end

    def attributes
      attributes = {
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

      definitions = attributes # to emphasize that its the same thing
      task = Jets::Lambda::Task.new(@route.controller_name, @route.action_name,
               resources: definitions)
      Attributes.new(attributes, task)
    end
    alias_method :resource, :attributes
    memoize :attributes

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
      path.gsub('/','_').gsub(':','').gsub('*','')
    end
  end
end
